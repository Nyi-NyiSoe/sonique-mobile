import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/playback_status.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_state.dart';

class MusicPlayerBloc extends Bloc<MusicEvent, MusicPlayerState> {
  MusicPlayerBloc() : super(const MusicPlayerState()) {
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
  }

  void _onPlaySong(PlaySong event, Emitter<MusicPlayerState> emit) {
    final newQueue = List<Song>.from(state.queue);

    // If no song is playing, set as current
    if (state.status == PlayBackStatus.stopped || state.currentSong == null) {
      emit(
        state.copyWith(currentSong: event.song, status: PlayBackStatus.playing),
      );
    } else {
      // Add to queue if already playing something else
      newQueue.add(event.song);
      emit(state.copyWith(queue: newQueue));
    }
  }

  void _onAddToQueue(AddToQueue event, Emitter<MusicPlayerState> emit) {
    final newQueue = List<Song>.from(state.queue)..add(event.song);
    emit(state.copyWith(queue: newQueue));
  }

  void _onPauseSong(PauseSong event, Emitter<MusicPlayerState> emit) {
    emit(state.copyWith(status: PlayBackStatus.paused));
  }

  void _onResumeSong(ResumeSong event, Emitter<MusicPlayerState> emit) {
    emit(state.copyWith(status: PlayBackStatus.playing));
  }

  void _onStopSong(StopSong event, Emitter<MusicPlayerState> emit) {
    emit(const MusicPlayerState()); // reset everything
  }

  void _onNextSong(NextSong event, Emitter<MusicPlayerState> emit) {
    if (state.queue.isEmpty) {
      if (state.repeat) {
        emit(
          state.copyWith(
            status: PlayBackStatus.playing,
            position: Duration.zero,
          ),
        );
      } else {
        emit(state.copyWith(status: PlayBackStatus.stopped, currentSong: null));
      }
      return;
    }

    final nextSong =
        state.shuffle
            ? (state.queue..shuffle(Random())).first
            : state.queue.first;

    final updatedQueue = List<Song>.from(state.queue)..remove(nextSong);

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
    // This could be improved by keeping a "history" stack
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
}
