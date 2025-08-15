import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/services/song_service.dart';
import 'package:sonique/Domain/usecases/song_data_usecase.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';

class SongDataBloc extends Bloc<SongDataEvent, SongDataState> {
  final SongDataUsecase songDataUsecase;
  final SongService songService;

  SongDataBloc({required this.songDataUsecase,required this.songService})
    : super(SongDataInitialState()) {
    on<FetchAllSongEvent>((event, emit) async {
      emit(SongDataLoadingState());
      try {
        final songs = await songService.fetchSongs();
        final genres = await songService.getGenre();

        emit(
          SongDataFetchedState(
            songs: songs.songs,
            hasMore: songs.hasMore,
            cursor: songs.nextCursor,
            genres: genres,
          ),
        );
      } catch (e) {
        emit(SongDataErrorState(error: e.toString()));
      }
    });

    on<FetchMoreSongEvent>((event, emit) async {
      final currentState = state;
      if (currentState is SongDataFetchedState) {
        try {
          final songResponse = await songService.fetchMoreSongs(
            currentState.cursor,
          );
          final genres = await songService.getGenre();
          if (songResponse.hasMore) {
            emit(
              SongDataFetchedState(
                songs: currentState.songs + songResponse.songs,
                hasMore: songResponse.hasMore,
                cursor: songResponse.nextCursor,
                genres: genres,
              ),
            );
          } else {
            emit(
              SongDataFetchedState(
                songs: currentState.songs + songResponse.songs,
                hasMore: false,
                cursor: currentState.cursor,
                genres: genres,
              ),
            );
          }
        } catch (e) {
          emit(SongDataErrorState(error: e.toString()));
        }
      }
    });

    on<UploadSongGenreEvent>((event, emit) async {
      emit(SongDataLoadingState());
      try {
        await songDataUsecase.uploadSongGenre(event.genreName);

        add(FetchAllSongEvent());
      } catch (e) {
        emit(SongDataErrorState(error: e.toString()));
      }
    });
  }
}
