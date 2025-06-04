class SongDataEvent {}

class FetchAllSongEvent extends SongDataEvent {}

class FetchMoreSongEvent extends SongDataEvent {}

class FetchSongGenreEvent extends SongDataEvent {}

class FetchSongByIdEvent extends SongDataEvent {
  final String songId;

  FetchSongByIdEvent({required this.songId});
}
