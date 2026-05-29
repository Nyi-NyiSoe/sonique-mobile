abstract class AlbumByArtistEvent {}

class FetchAlbumByArtistIdEvent extends AlbumByArtistEvent {
  final int? artistId;
  final bool forceRefresh;

  FetchAlbumByArtistIdEvent(this.artistId, {this.forceRefresh = false});
}
