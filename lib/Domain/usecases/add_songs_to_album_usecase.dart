import 'package:sonique/Domain/repository/album_repository.dart';

class AddSongsToAlbumUsecase {
  final AlbumRepository repository;

  AddSongsToAlbumUsecase(this.repository);

  Future<void> call(Set<String> songIds, int albumId) {
    return repository.addSongsToAlbum(songIds, albumId);
  }
}