import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/repository/album_repository.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_state.dart';

class AlbumByArtistBloc extends Bloc<AlbumByArtistEvent, AlbumByArtistState> {
  final AlbumRepository albumRepository;
  AlbumByArtistBloc({required this.albumRepository}):super(AlbumByArtistInitial()){
    on<FetchAlbumByArtistIdEvent>(_onFetchAlbumByArtistId);
  }

  Future<void> _onFetchAlbumByArtistId(FetchAlbumByArtistIdEvent event,Emitter<AlbumByArtistState> emit)async{
   
   emit(AlbumByArtistLoading());
    try{
        final albums = await albumRepository.getAlbumByArtistId(event.artistId);
        emit(AlbumByArtistLoaded(albums));
    }catch (e){
      emit(AlbumByArtistError(e.toString()));
    }
  }
}
