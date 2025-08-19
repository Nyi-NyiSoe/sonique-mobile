class SongDataEvent {}

class FetchAllSongEvent extends SongDataEvent {}

class FetchMoreSongEvent extends SongDataEvent {}

class FetchSongByIdEvent extends SongDataEvent {
  final String songId;

  FetchSongByIdEvent({required this.songId});
}

class UploadSongGenreEvent extends SongDataEvent{
  final String genreName;
  UploadSongGenreEvent({required this.genreName});
}
