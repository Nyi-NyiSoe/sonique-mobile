import 'package:sonique/Data/models/album_detail_model.dart';

abstract class AlbumDetailState {}

class AlbumDetailInitial extends AlbumDetailState {}

class AlbumDetailLoading extends AlbumDetailState {}

class AlbumDetailLoaded extends AlbumDetailState {
  final AlbumDetailModel album;
  AlbumDetailLoaded(this.album);
}

class AlbumDetailError extends AlbumDetailState {
  final String error;
  AlbumDetailError(this.error);
}
