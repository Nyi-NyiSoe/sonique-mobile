import 'package:image_picker/image_picker.dart';
import 'package:sonique/Domain/repository/album_repository.dart';

class CreateAlbumUsecase{
  final AlbumRepository repository;

  CreateAlbumUsecase(this.repository);

  Future<void> call(String name, XFile coverImage, String description) {
    return repository.createAlbum(name, coverImage, description);
  }
}