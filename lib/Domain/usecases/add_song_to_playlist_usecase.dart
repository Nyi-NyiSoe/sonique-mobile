import 'package:sonique/Domain/repository/playlist_repository.dart';

class AddSongToPlaylistUsecase {
   final PlaylistRepository repo;
  AddSongToPlaylistUsecase(this.repo);
  Future<void> call(int playlistId, String songId) {
    return repo.addToPlaylist(playlistId,songId);
  }
}