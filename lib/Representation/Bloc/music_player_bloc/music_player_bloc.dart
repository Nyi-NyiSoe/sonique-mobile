import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/playback_status.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_state.dart';

class MusicPlayerBloc extends Bloc<MusicEvent, MusicPlayerState> {
  final AudioPlayer _player = AudioPlayer();

  MusicPlayerBloc() : super(const MusicPlayerState()) {
    // Event handlers
    on<PlaySong>(_onPlaySong);
    on<AddToQueue>(_onAddToQueue);
    on<PauseSong>(_onPauseSong);
    on<ResumeSong>(_onResumeSong);
    on<StopSong>(_onStopSong);
    on<NextSong>(_onNextSong);
    on<PreviousSong>(_onPreviousSong);
    on<UpdatePosition>(_onUpdatePosition);
    on<ToggleShuffle>(_onToggleShuffle);
    on<ToggleRepeat>(_onToggleRepeat);
    on<ReorderQueue>(_onReorderQueue);

    // Listen for completion to auto-play next song
    _player.onPlayerComplete.listen((_) {
      add(NextSong());
    });

    // Listen to position changes for mini-player
    _player.onPositionChanged.listen((pos) {
      add(UpdatePosition(pos));
    });
  }

  Future<void> _onPlaySong(
    PlaySong event,
    Emitter<MusicPlayerState> emit,
  ) async {
    // Stop current song if any
    await _player.stop();

    // Start new song
    await _player.play(UrlSource(event.song.audioUrl));

    // Update state
    emit(
      state.copyWith(
        currentSong: event.song,
        status: PlayBackStatus.playing,
        position: Duration.zero,
      ),
    );
  }

  void _onAddToQueue(AddToQueue event, Emitter<MusicPlayerState> emit) {
    final newQueue = List<Song>.from(state.queue)..add(event.song);
    emit(state.copyWith(queue: newQueue));
  }

  void _onPauseSong(PauseSong event, Emitter<MusicPlayerState> emit) {
    _player.pause();
    emit(state.copyWith(status: PlayBackStatus.paused));
  }

  void _onResumeSong(ResumeSong event, Emitter<MusicPlayerState> emit) {
    _player.resume();
    emit(state.copyWith(status: PlayBackStatus.playing));
  }

  void _onStopSong(StopSong event, Emitter<MusicPlayerState> emit) {
    _player.stop();
    emit(const MusicPlayerState());
  }

  void _onNextSong(NextSong event, Emitter<MusicPlayerState> emit) async {
    if (state.queue.isEmpty) {
      if (state.repeat && state.currentSong != null) {
        // Repeat current song
        await _player.seek(Duration.zero);
        await _player.resume();
        emit(
          state.copyWith(
            status: PlayBackStatus.playing,
            position: Duration.zero,
          ),
        );
      } else {
        await _player.stop();
        emit(state.copyWith(currentSong: null, status: PlayBackStatus.stopped));
      }
      return;
    }

    // Determine next song
    final nextSong =
        state.shuffle
            ? (List<Song>.from(state.queue)..shuffle()).first
            : state.queue.first;

    final updatedQueue = List<Song>.from(state.queue)..remove(nextSong);

    await _player.stop();
    await _player.play(UrlSource(nextSong.audioUrl));

    emit(
      state.copyWith(
        currentSong: nextSong,
        queue: updatedQueue,
        status: PlayBackStatus.playing,
        position: Duration.zero,
      ),
    );
  }

  void _onPreviousSong(PreviousSong event, Emitter<MusicPlayerState> emit) {
    // Optional: implement history stack
    _player.seek(Duration.zero);
    emit(state.copyWith(position: Duration.zero));
  }

  void _onUpdatePosition(UpdatePosition event, Emitter<MusicPlayerState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onToggleShuffle(ToggleShuffle event, Emitter<MusicPlayerState> emit) {
    emit(state.copyWith(shuffle: !state.shuffle));
  }

  void _onToggleRepeat(ToggleRepeat event, Emitter<MusicPlayerState> emit) {
    emit(state.copyWith(repeat: !state.repeat));
  }

  void _onReorderQueue(ReorderQueue event, Emitter<MusicPlayerState> emit) {
    final updatedQueue = List<Song>.from(state.queue);

    final song = updatedQueue.removeAt(event.oldIndex);
    updatedQueue.insert(event.newIndex, song);
    emit(state.copyWith(queue: updatedQueue));
  }
}
