import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/repository/album_repository.dart';
import 'package:sonique/Domain/usecases/add_songs_to_album_usecase.dart';
import 'package:sonique/Domain/usecases/create_album_usecase.dart';
import 'package:sonique/Domain/usecases/remove_songs_from_album_usecase.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_state.dart';

class AlbumOperationsBloc
    extends Bloc<AlbumOperationsEvent, AlbumOperationsState> {
  final AlbumRepository albumRepository;
  final CreateAlbumUsecase createAlbumUsecase;
  final AddSongsToAlbumUsecase addSongsToAlbumUsecase;
  final RemoveSongsFromAlbumUsecase removeSongsFromAlbumUsecase;

  AlbumOperationsBloc({
    required this.albumRepository,
    required this.createAlbumUsecase,
    required this.addSongsToAlbumUsecase,
    required this.removeSongsFromAlbumUsecase
  }) : super(AlbumOperationInitial()) {
    on<CreateAlbumEvent>(_onCreateAlbum);
    on<AddSongsToAlbumEvent>(_onAddSongsToAlbum);
    on<RemoveSongsFromAlbumEvent>(_onRemoveSongsFromAlbum);
  }

  Future<void> _onCreateAlbum(
    CreateAlbumEvent event,
    Emitter<AlbumOperationsState> emit,
  ) async {
    emit(AlbumOperationLoading());
    try {
      await createAlbumUsecase(event.name, event.coverImage, event.description);

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
      await addSongsToAlbumUsecase(event.songIds, event.albumId);
      emit(AlbumOperationSuccess('success'));
    } catch (e) {
      print('[AlbumOperationBloc] Error fetching album detail: $e');
      emit(AlbumOperationError(e.toString()));
    }
  }

  Future<void> _onRemoveSongsFromAlbum(
    RemoveSongsFromAlbumEvent event,
    Emitter<AlbumOperationsState> emit,
  ) async {
    emit(AlbumOperationLoading());
    try {
      await removeSongsFromAlbumUsecase(event.songIds, event.albumId);
      emit(AlbumOperationSuccess('success'));
    } catch (e) {
      print('[AlbumOperationBloc] Error fetching album detail: $e');
      emit(AlbumOperationError(e.toString()));
    }
  }
}
