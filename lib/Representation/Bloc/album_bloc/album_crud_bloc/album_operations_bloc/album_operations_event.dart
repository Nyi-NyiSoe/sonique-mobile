import 'package:image_picker/image_picker.dart';

abstract class AlbumOperationsEvent {}

class CreateAlbumEvent extends AlbumOperationsEvent {
  final String name;
  final XFile coverImage;
  final String description;
  CreateAlbumEvent(this.name, this.coverImage,this.description);
}
