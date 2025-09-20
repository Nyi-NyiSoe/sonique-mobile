

import 'package:sonique/Data/models/album_model.dart';

abstract class AlbumListState {}

class AlbumInitial extends AlbumListState {}

class AlbumListLoading extends AlbumListState {}

class AlbumListLoaded extends AlbumListState {
  final List<AlbumModel> albums;
  AlbumListLoaded(this.albums);
}

class AlbumListError extends AlbumListState{
  final String error;
  AlbumListError(this.error);
}