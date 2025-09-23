abstract class PlaylistEvent {}

class FetchUserPlaylistEvent extends PlaylistEvent {}

class FetchPlaylistDetailevent extends PlaylistEvent {
  final int playlistId;
  FetchPlaylistDetailevent({required this.playlistId});
}

class CreatePlaylistEvent extends PlaylistEvent {
  final String name;
  CreatePlaylistEvent({required this.name});
}

class AddToPlaylistEvent extends PlaylistEvent {
  final int playlistId;
  final String songId;
  AddToPlaylistEvent({required this.playlistId, required this.songId});
}

class RemoveFromPlaylistEvent extends PlaylistEvent {
  final int playlistId;
  final String songId;
  RemoveFromPlaylistEvent({required this.playlistId, required this.songId});
}

class ResetLikeBlocEvent extends PlaylistEvent {}
