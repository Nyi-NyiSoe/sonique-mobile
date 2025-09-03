import 'package:sonique/Data/models/liked_song_model.dart';
import 'package:sonique/Data/models/song_data_status.dart';

class LikeSongState {
  final List<LikedSongModel> likedSongs;
  final SongDataStatus status;
  final String? error;

  const LikeSongState({
    this.likedSongs = const [],
    this.status = SongDataStatus.initial,
    this.error,
  });

  LikeSongState copyWith({
    List<LikedSongModel>? likedSongs,
    SongDataStatus? status,
    String? error,
  }) {
    return LikeSongState(
      likedSongs: likedSongs ?? this.likedSongs,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
