import 'package:sonique/Domain/entities/song.dart';

abstract class MusicEvent {}

class PlaySong extends MusicEvent {
  final Song song;
  PlaySong(this.song);
}

class AddToQueue extends MusicEvent {
  final Song song;
  AddToQueue(this.song);
}

class PauseSong extends MusicEvent {}
class ResumeSong extends MusicEvent {}
class StopSong extends MusicEvent {}
class NextSong extends MusicEvent {}
class PreviousSong extends MusicEvent {}
class UpdatePosition extends MusicEvent {
  final Duration position;
  UpdatePosition(this.position);
}
class ToggleShuffle extends MusicEvent {}
class ToggleRepeat extends MusicEvent {}

class ReorderQueue extends MusicEvent{
  final int oldIndex;
  final int newIndex;
  ReorderQueue({required this.oldIndex,required this.newIndex});
}

class ResetPlayer extends MusicEvent{}

class SeekToEvent extends MusicEvent{
  final Duration position;
 
  SeekToEvent(this.position);
}
