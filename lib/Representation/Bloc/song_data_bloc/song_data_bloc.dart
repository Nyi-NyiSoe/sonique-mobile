import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Data/services/song_service.dart';
import 'package:sonique/Domain/usecases/song_data_usecase.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';

class SongDataBloc extends Bloc<SongDataEvent, SongDataState> {
  final SongDataUsecase songDataUsecase;
  final SongService songService;

  SongDataBloc({required this.songDataUsecase, required this.songService})
    : super(const SongDataState()) {
    on<FetchAllSongEvent>(_onFetchAllSongs);
    on<FetchMoreSongEvent>(_onFetchMoreSongs);
    on<UploadSongGenreEvent>(_onUploadSongGenre);
    on<UploadSongEvent>(_onUploadSong);
  }

  Future<void> _onFetchAllSongs(
    FetchAllSongEvent event,
    Emitter<SongDataState> emit,
  ) async {
    emit(state.copyWith(fetchStatus: SongDataStatus.loading));

    try {
      final songs = await songService.fetchSongs();
      final genres = await songService.getGenre();

      emit(
        state.copyWith(
          songs: songs.songs,
          hasMore: songs.hasMore,
          cursor: songs.nextCursor,
          genres: genres,
          fetchStatus: SongDataStatus.success,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          fetchStatus: SongDataStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchMoreSongs(
    FetchMoreSongEvent event,
    Emitter<SongDataState> emit,
  ) async {
    if (state.hasMore && state.fetchStatus != SongDataStatus.loading) {
      try {
        final songResponse = await songService.fetchMoreSongs(state.cursor);
        final genres = await songService.getGenre();

        emit(
          state.copyWith(
            songs: state.songs + songResponse.songs,
            hasMore: songResponse.hasMore,
            cursor: songResponse.nextCursor,
            genres: genres,
            fetchStatus: SongDataStatus.success,
            error: null,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            fetchStatus: SongDataStatus.failure,
            error: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _onUploadSongGenre(
    UploadSongGenreEvent event,
    Emitter<SongDataState> emit,
  ) async {
    emit(state.copyWith(uploadStatus: SongDataStatus.loading));

    try {
      await songDataUsecase.uploadSongGenre(event.genreName);

      // refresh songs after upload
      add(FetchAllSongEvent());

      emit(state.copyWith(uploadStatus: SongDataStatus.success, error: null));
    } catch (e) {
      emit(
        state.copyWith(
          uploadStatus: SongDataStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUploadSong(
    UploadSongEvent event,
    Emitter<SongDataState> emit,
  ) async {
    emit(state.copyWith(uploadStatus: SongDataStatus.loading));

    try {
      await songService.uploadSong(
        event.audioFile,
        event.coverImage,
        event.genreId,
        event.title,
      );

      add(FetchAllSongEvent());
      emit(state.copyWith(uploadStatus: SongDataStatus.success, error: null));
    } catch (e) {
      state.copyWith(uploadStatus: SongDataStatus.failure, error: e.toString());
    }
  }
}
