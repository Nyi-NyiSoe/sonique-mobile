import 'package:image_picker/image_picker.dart';

class SongDataEvent {}

class FetchAllSongEvent extends SongDataEvent {}

class FetchMoreSongEvent extends SongDataEvent {}

class FetchSongByIdEvent extends SongDataEvent {
  final String songId;

  FetchSongByIdEvent({required this.songId});
}

class UploadSongGenreEvent extends SongDataEvent {
  final String genreName;
  UploadSongGenreEvent({required this.genreName});
}

class UploadSongEvent extends SongDataEvent {
  final XFile audioFile;
  final XFile coverImage;
  final String genreId;
  final String title;
  UploadSongEvent({
    required this.audioFile,
    required this.coverImage,
    required this.genreId,
    required this.title,
  });
}
