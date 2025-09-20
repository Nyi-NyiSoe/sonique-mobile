abstract class AlbumDetailEvent {}

class AlbumInitial extends AlbumDetailEvent{}

class FetchAlbumDetailEvent extends AlbumDetailEvent{
  final int albumId;
  FetchAlbumDetailEvent(this.albumId);
}