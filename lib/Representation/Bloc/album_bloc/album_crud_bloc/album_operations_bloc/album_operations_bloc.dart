import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/repository/album_repository.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_state.dart';

class AlbumOperationsBloc
    extends Bloc<AlbumOperationsEvent, AlbumOperationsState> {
  final AlbumRepository albumRepository;

  AlbumOperationsBloc({required this.albumRepository})
    : super(AlbumOperationInitial()) {
    on<CreateAlbumEvent>(_onCreateAlbum);
    on<AddSongsToAlbumEvent>(_onAddSongsToAlbum);
  }

  Future<void> _onCreateAlbum(
    CreateAlbumEvent event,
    Emitter<AlbumOperationsState> emit,
  ) async {
    emit(AlbumOperationLoading());
    try {
      await albumRepository.createAlbum(
        event.name,
        event.coverImage,
        event.description,
      );

      print('Album created successfully');
      emit(AlbumOperationSuccess('success'));
    } catch (e) {
      print('[AlbumOperationBloc] Error fetching album detail: $e');
      emit(AlbumOperationError(e.toString()));
    }
  }

  Future<void> _onAddSongsToAlbum(
    AddSongsToAlbumEvent event,
    Emitter<AlbumOperationsState> emit,
  ) async {
    emit(AlbumOperationLoading());
    try {
      await albumRepository.addSongsToAlbum(event.songIds, event.albumId);
      emit(AlbumOperationSuccess('success'));
    } catch (e) {
      print('[AlbumOperationBloc] Error fetching album detail: $e');
      emit(AlbumOperationError(e.toString()));
    }
  }
}
