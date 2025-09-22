import 'package:sonique/Data/models/playback_status.dart';
import 'package:sonique/Data/models/song_model.dart';
enum RepeatMode{
  off,
  all,
  one
}
class MusicPlayerState {
  final List<SongModel> queue;
  final List<SongModel> history;
  final SongModel? currentSong;
  final PlayBackStatus status;
  final Duration position;
  final bool shuffle;
  final RepeatMode repeatMode;
  const MusicPlayerState({
    this.queue = const [],
    this.history = const [],
    this.currentSong,
    this.status = PlayBackStatus.stopped,
    this.position = Duration.zero,
    this.shuffle = false,
    this.repeatMode = RepeatMode.off,
  });

  MusicPlayerState copyWith({
    List<SongModel>? queue,
    List<SongModel>? history,
    SongModel? currentSong,
    PlayBackStatus? status,
    Duration? position,
    bool? shuffle,
    RepeatMode? repeatMode,
  }) {
    return MusicPlayerState(
      queue: queue ?? this.queue,
      history: history ?? this.history,
      currentSong: currentSong ?? this.currentSong,
      status: status ?? this.status,
      position: position ?? this.position,
      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode
    );
  }

  factory MusicPlayerState.initial() {
    return const MusicPlayerState(
      queue: [],
      currentSong: null,
      status: PlayBackStatus.stopped,
      position: Duration.zero,
      shuffle: false,
      repeatMode: RepeatMode.off,
    );
  }
}
