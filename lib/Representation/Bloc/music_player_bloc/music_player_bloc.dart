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
    on<PlayAList>(_onPlayAList);
    on<ShufflePlay>(_onShufflePlay);
    on<ResetPlayer>((event, emit) async {
      await _player.stop();
      emit(MusicPlayerState.initial());
    });
    on<SeekToEvent>((_seekToEvent));

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
    // Stop any current playback
    await _player.stop();

    // Play the selected song
    await _player.play(UrlSource(event.song.audioUrl));

    // Emit a fresh state
    emit(
      state.copyWith(
        queue: [],
        history: [],
        currentSong: event.song,
        status: PlayBackStatus.playing,
        position: Duration.zero,
        shuffle: false, // reset shuffle
        repeatMode: RepeatMode.off, // reset repeat
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

  Future<void> _onNextSong(
    NextSong event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (state.currentSong == null) return;

    final updatedHistory = List<Song>.from(state.history)
      ..add(state.currentSong!);

    if (state.repeatMode == RepeatMode.one) {
      // Repeat current song
      await _player.seek(Duration.zero);
      await _player.resume();

      emit(
        state.copyWith(
          status: PlayBackStatus.playing,
          position: Duration.zero,
          history: updatedHistory,
        ),
      );
      return;
    }

    if (state.queue.isEmpty) {
      if (state.repeatMode == RepeatMode.all && state.history.isNotEmpty) {
        // Restart the whole playlist
        final allSongs = [...state.history, state.currentSong!];
        final firstSong = allSongs.first;

        await _player.stop();
        await _player.play(UrlSource(firstSong.audioUrl));

        emit(
          state.copyWith(
            currentSong: firstSong,
            queue: allSongs.skip(1).toList(),
            history: [],
            status: PlayBackStatus.playing,
            position: Duration.zero,
          ),
        );
      } else {
        // No repeat → stop
        await _player.stop();
        emit(state.copyWith(currentSong: null, status: PlayBackStatus.stopped));
      }
      return;
    }

    // Play next song from queue (shuffle or normal)
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
        history: updatedHistory,
        status: PlayBackStatus.playing,
        position: Duration.zero,
      ),
    );
  }

  void _onPreviousSong(
    PreviousSong event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (state.position > const Duration(seconds: 3)) {
      // If played more than 3s, restart current track
      await _player.seek(Duration.zero);
      emit(state.copyWith(position: Duration.zero));
      return;
    }

    if (state.history.isEmpty) {
      // No previous song → just restart
      await _player.seek(Duration.zero);
      emit(state.copyWith(position: Duration.zero));
      return;
    }

    final prevSong = state.history.last;
    final updatedHistory = List<Song>.from(state.history)..removeLast();

    await _player.stop();
    await _player.play(UrlSource(prevSong.audioUrl));

    emit(
      state.copyWith(
        currentSong: prevSong,
        history: updatedHistory,
        queue: [
          state.currentSong!,
          ...state.queue,
        ], // put current back to queue
        status: PlayBackStatus.playing,
        position: Duration.zero,
      ),
    );
  }

  void _seekToEvent(SeekToEvent event, Emitter<MusicPlayerState> emit) async {
    await _player.seek(event.position);
    emit(state.copyWith(position: event.position));
  }

  void _onUpdatePosition(
    UpdatePosition event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(position: event.position));
  }

  void _onToggleShuffle(ToggleShuffle event, Emitter<MusicPlayerState> emit) {
    if (!state.shuffle && state.queue.isNotEmpty) {
      // Turning shuffle ON → shuffle the current queue
      final shuffledQueue = List<Song>.from(state.queue)..shuffle();
      emit(state.copyWith(shuffle: true, queue: shuffledQueue));
    } else {
      // Turning shuffle OFF → you may want to restore original order
      // For now, just flip shuffle flag without touching queue
      emit(state.copyWith(shuffle: false));
    }
  }

  Future<void> _onShufflePlay(
    ShufflePlay event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (event.songs.isEmpty) return;

    // Stop current playback
    await _player.stop();

    // Shuffle the list
    final shuffled = List<Song>.from(event.songs)..shuffle();

    // Play the first song
    final firstSong = shuffled.first;
    await _player.play(UrlSource(firstSong.audioUrl));

    // Prepare the queue (rest of the shuffled songs)
    final queue = shuffled.skip(1).toList();

    emit(
      state.copyWith(
        currentSong: firstSong,
        queue: queue,
        history: [],
        shuffle: true, // mark shuffle ON
        status: PlayBackStatus.playing,
        position: Duration.zero,
        repeatMode: RepeatMode.off
      ),
    );
  }

  void _onToggleRepeat(ToggleRepeat event, Emitter<MusicPlayerState> emit) {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    emit(state.copyWith(repeatMode: nextMode));
  }

  void _onReorderQueue(ReorderQueue event, Emitter<MusicPlayerState> emit) {
    final updatedQueue = List<Song>.from(state.queue);

    final song = updatedQueue.removeAt(event.oldIndex);
    updatedQueue.insert(event.newIndex, song);
    emit(state.copyWith(queue: updatedQueue));
  }

  void _onPlayAList(PlayAList event, Emitter<MusicPlayerState> emit) async {
    if (event.songs.isEmpty) return;

    // Stop any current playback
    await _player.stop();

    // Play the first song in the list
    final firstSong = event.songs.first;
    await _player.play(UrlSource(firstSong.audioUrl));

    // Prepare the queue (excluding the first song)
    final queue = event.songs.skip(1).toList();

    emit(
      state.copyWith(
        currentSong: firstSong,
        queue: queue,
        history: [],
        status: PlayBackStatus.playing,
        position: Duration.zero,
        shuffle: false
      ),
    );
  }
}
