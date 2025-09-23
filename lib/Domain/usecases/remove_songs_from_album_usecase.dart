import 'package:sonique/Domain/repository/album_repository.dart';

class RemoveSongsFromAlbumUsecase {
  final AlbumRepository repository;

  RemoveSongsFromAlbumUsecase(this.repository);

  Future<void> call(String songIds, int albumId) {
    return repository.removeSongsFromAlbum(songIds, albumId);
  }
}
