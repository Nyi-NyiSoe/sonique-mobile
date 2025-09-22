import 'package:sonique/Data/models/album_model.dart';

abstract class AlbumByArtistState {}

class AlbumByArtistInitial extends AlbumByArtistState{}

class AlbumByArtistLoading extends AlbumByArtistState{}

class AlbumByArtistLoaded extends AlbumByArtistState{
  final List<AlbumModel> albums;
  AlbumByArtistLoaded(this.albums);
}

class AlbumByArtistError extends AlbumByArtistState{
  final String error;
  AlbumByArtistError(this.error);
}

