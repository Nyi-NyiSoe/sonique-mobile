import 'package:sonique/Domain/repository/playlist_repository.dart';

class CreatePlaylistUsecase {
  final PlaylistRepository repo;
  CreatePlaylistUsecase(this.repo);
  Future<void> call(String name) {
    return repo.createPlaylist(name);
  }
}
