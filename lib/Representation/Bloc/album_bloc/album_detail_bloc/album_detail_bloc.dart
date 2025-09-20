import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/repository/album_repository.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_state.dart';

class AlbumDetailBloc extends Bloc<AlbumDetailEvent, AlbumDetailState> {
  final AlbumRepository albumRepository;
  AlbumDetailBloc({required this.albumRepository})
    : super(AlbumDetailInitial()) {
    on<FetchAlbumDetailEvent>(_onFetchAlbumDetail);
  }

  Future<void> _onFetchAlbumDetail(
    FetchAlbumDetailEvent event,
    Emitter<AlbumDetailState> emit,
  ) async {
    print('[AlbumDetailBloc] Fetching album detail for id: ${event.albumId}');
    emit(AlbumDetailLoading());
    try {
      final album = await albumRepository.getAlbumDetail(event.albumId);
      print('[AlbumDetailBloc] Album detail loaded: $album');
      emit(AlbumDetailLoaded(album));
    } catch (e) {
      print('[AlbumDetailBloc] Error fetching album detail: $e');
      emit(AlbumDetailError(e.toString()));
    }
  }
}
