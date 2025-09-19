import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Data/services/song_service.dart';
import 'package:sonique/Domain/usecases/song_data_usecase.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';

class LikesBloc extends Bloc<LikeSongEvent, LikeSongState> {
  final SongDataUsecase songDataUsecase;
  final SongService songService;
  LikesBloc({required this.songDataUsecase, required this.songService})
    : super(const LikeSongState()) {
    on<LoadLikedSongs>(_onLoadLikedSongs);
    on<LikeSong>(_onLikeSong);
    on<UnlikeSong>(_onUnlikeSong);
  }

  Future<void> _onLoadLikedSongs(
    LoadLikedSongs event,
    Emitter<LikeSongState> emit,
  ) async {
    try {
      log("_onLoadLikedSongs called"); // 👈 check event dispatch
      emit(state.copyWith(status: SongDataStatus.loading));

      final likedSongs = await songService.loadLikedSongs();
      log("Loaded liked songs: ${likedSongs.length}");
      for (var s in likedSongs) {
        log(s.toString()); // print each song
      }

      emit(
        state.copyWith(likedSongs: likedSongs, status: SongDataStatus.success),
      );
      log("Emitted success state with ${likedSongs.length} songs");
    } catch (e, s) {
      log("Error in _onLoadLikedSongs: $e");
      log("Stacktrace: $s");
      emit(state.copyWith(status: SongDataStatus.failure, error: e.toString()));
    }
  }

  void _onLikeSong(LikeSong event, Emitter<LikeSongState> emit) async {
    try {
      emit(state.copyWith(status: SongDataStatus.loading));
      // Like the song via service
      await songService.likeASong(event.songId);
      // Add to liked songs if not already present
      add(LoadLikedSongs());

      emit(state.copyWith(status: SongDataStatus.success));
    } catch (e) {
      emit(state.copyWith(status: SongDataStatus.failure, error: e.toString()));
    }
  }

  void _onUnlikeSong(UnlikeSong event, Emitter<LikeSongState> emit) {
    final updated =
        state.likedSongs.where((s) => s.id != event.songId).toList();
    emit(state.copyWith(likedSongs: updated));
  }
}
