abstract class AlbumByArtistEvent {}

class FetchAlbumByArtistIdEvent extends AlbumByArtistEvent{
  final int artistId;
  FetchAlbumByArtistIdEvent(this.artistId);
}