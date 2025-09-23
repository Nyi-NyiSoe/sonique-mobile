abstract class AlbumOperationsState {}

class AlbumOperationInitial extends AlbumOperationsState {}

class AlbumOperationLoading extends AlbumOperationsState {}

class AlbumOperationSuccess extends AlbumOperationsState {
  final String success;
  AlbumOperationSuccess(this.success);
}

class AlbumOperationError extends AlbumOperationsState {
  final String error;
  AlbumOperationError(this.error);
}
