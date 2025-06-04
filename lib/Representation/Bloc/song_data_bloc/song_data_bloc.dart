import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/usecases/song_data_usecase.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';

class SongDataBloc extends Bloc<SongDataEvent, SongDataState> {
  final SongDataUsecase songDataUsecase;

  SongDataBloc({required this.songDataUsecase})
    : super(SongDataInitialState()) {
    on<FetchAllSongEvent>((event, emit) async {
      emit(SongDataLoadingState());
      try {
        final songs = await songDataUsecase.getAllSongs();

        emit(
          SongDataFetchedState(
            songs: songs.songs,
            hasMore: songs.hasMore,
            cursor: songs.nextCursor,
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
          final songResponse = await songDataUsecase.getMoreSongs(currentState.cursor);
          if (songResponse.hasMore) {
            emit(
              SongDataFetchedState(
                songs: currentState.songs + songResponse.songs,
                hasMore: songResponse.hasMore,
                cursor: songResponse.nextCursor,
              ),
            );
          } else {
            emit(
              SongDataFetchedState(
                songs: currentState.songs + songResponse.songs,
                hasMore: false,
                cursor: currentState.cursor,
              ),
            );
          }
        } catch (e) {
          emit(SongDataErrorState(error: e.toString()));
        }
      }
    });

    on<FetchSongGenreEvent>((event,emit) async{
      emit(GenreLoadingState());
      try{
        final genres = await songDataUsecase.getGenre();
        emit(GenreFetchedState(genres: genres));
      }catch (e){
        emit(GenreFetchingErrorState(error: e.toString()));
      }
    });
  }
}
