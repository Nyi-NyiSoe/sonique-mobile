import 'package:sonique/Data/models/playback_status.dart';
import 'package:sonique/Domain/entities/song.dart';



class MusicPlayerState {
  final List<Song> queue;
  final Song? currentSong;
  final PlayBackStatus status;
  final Duration position;
  final bool shuffle;
  final bool repeat;
  const MusicPlayerState({
    this.queue = const [],
    this.currentSong,
    this.status = PlayBackStatus.stopped,
    this.position = Duration.zero,
    this.shuffle = false,
    this.repeat = false,
  });

  MusicPlayerState copyWith({
    List<Song>? queue,
    Song? currentSong,
    PlayBackStatus? status,
    Duration? position,
    bool? shuffle,
    bool? repeat,
  }) {
    return MusicPlayerState(
      queue: queue ?? this.queue,
      currentSong: currentSong ?? this.currentSong,
      status: status ?? this.status,
      position: position ?? this.position,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
    );
  }
}
