import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/repository/album_repository.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_state.dart';

class AlbumListBloc extends Bloc<AlbumListEvent, AlbumListState> {
  final AlbumRepository albumRepository;
  AlbumListBloc({required this.albumRepository})
    : super( AlbumInitial()) {
      on<FetchAlbumsEvent>(_onFetchAlbums);
    }

    Future<void> _onFetchAlbums(FetchAlbumsEvent event, Emitter<AlbumListState> emit) async {
      emit(AlbumListLoading());
      try {
         final albums = await albumRepository.getAllAlbums();
         print(albums);
        emit(AlbumListLoaded(albums));
      } catch (e) {
        emit(AlbumListError(e.toString()));
      }
    }
}
