import 'package:image_picker/image_picker.dart';

abstract class AlbumOperationsEvent {}

class CreateAlbumEvent extends AlbumOperationsEvent {
  final String name;
  final XFile coverImage;
  final String description;
  CreateAlbumEvent(this.name, this.coverImage,this.description);
}

class AddSongsToAlbumEvent extends AlbumOperationsEvent{
  final Set<String> songIds;
  final int albumId;
  AddSongsToAlbumEvent(this.songIds,this.albumId);
}

class RemoveSongsFromAlbumEvent extends AlbumOperationsEvent{
  final String songIds;
  final int albumId;
  RemoveSongsFromAlbumEvent(this.songIds,this.albumId);
}
