import 'package:sonique/Domain/repository/playlist_repository.dart';

class RemoveSongFromPlaylistUsecase {
  final PlaylistRepository repo;
  RemoveSongFromPlaylistUsecase(this.repo);
  Future<void> call(int playlistId, String songId) {
    return repo.removeFromPlaylist(playlistId, songId);
  }
}
