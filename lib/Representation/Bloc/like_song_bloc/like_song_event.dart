abstract class LikeSongEvent {}

class LikeSong extends LikeSongEvent {
  final String songId;
  LikeSong(this.songId);
}

class UnlikeSong extends LikeSongEvent {
  final String songId;
  UnlikeSong(this.songId);
}

class LoadLikedSongs extends LikeSongEvent {
}

class ResetBlocEvent extends LikeSongEvent{
  
}
