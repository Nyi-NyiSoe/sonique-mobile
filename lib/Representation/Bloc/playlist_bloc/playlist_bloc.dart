import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/repository/playlist_repository.dart';
import 'package:sonique/Domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:sonique/Domain/usecases/create_playlist_usecase.dart';
import 'package:sonique/Domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  static const Duration _cacheDuration = Duration(minutes: 3);

  final PlaylistRepository playlistRepository;
  final CreatePlaylistUsecase createPlaylistUsecase;
  final AddSongToPlaylistUsecase addSongToPlaylistUsecase;
  final RemoveSongFromPlaylistUsecase removeSongFromPlaylistUsecase;
  DateTime? _lastFetchedAt;

  PlaylistBloc({
    required this.playlistRepository,
    required this.createPlaylistUsecase,
    required this.addSongToPlaylistUsecase,
    required this.removeSongFromPlaylistUsecase,
  }) : super(const PlaylistState()) {
    on<FetchUserPlaylistEvent>(_onFetchUserPlaylist);
    on<FetchPlaylistDetailevent>(_onFetchPlaylistDetail);
    on<CreatePlaylistEvent>(_onCreatePlaylist);
    on<AddToPlaylistEvent>(_onAddToPlaylist);
    on<RemoveFromPlaylistEvent>(_onRemoveFromPlaylist);
    on<ResetLikeBlocEvent>(
      (event, emit) => emit(
        state.copyWith(
          playlists: [],
          selectedPlaylist: null,
          status: PlaylistStatus.initial,
        ),
      ),
    );
  }

  Future<void> _onFetchUserPlaylist(
    FetchUserPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    final hasFreshCache =
        state.status == PlaylistStatus.success &&
        _lastFetchedAt != null &&
        DateTime.now().difference(_lastFetchedAt!) < _cacheDuration;

    if (hasFreshCache && !event.forceRefresh) {
      return;
    }

    if (state.playlists.isEmpty) {
      emit(state.copyWith(status: PlaylistStatus.loading));
    }

    try {
      final res = await playlistRepository.getUserPlaylist();
      _lastFetchedAt = DateTime.now();
      emit(state.copyWith(status: PlaylistStatus.success, playlists: res));
    } catch (e) {
      emit(state.copyWith(status: PlaylistStatus.error));
    }
  }

  Future<void> _onFetchPlaylistDetail(
    FetchPlaylistDetailevent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(state.copyWith(status: PlaylistStatus.loading));

    try {
      final res = await playlistRepository.getPlaylistDetail(event.playlistId);
      emit(
        state.copyWith(status: PlaylistStatus.success, selectedPlaylist: res),
      );
    } catch (e) {
      emit(state.copyWith(status: PlaylistStatus.error));
    }
  }

  Future<void> _onCreatePlaylist(
    CreatePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(state.copyWith(status: PlaylistStatus.loading));

    try {
      await createPlaylistUsecase(event.name);
      emit(state.copyWith(status: PlaylistStatus.success));
      add(FetchUserPlaylistEvent(forceRefresh: true));
    } catch (e) {
      emit(state.copyWith(status: PlaylistStatus.error));
    }
  }

  Future<void> _onAddToPlaylist(
    AddToPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(state.copyWith(status: PlaylistStatus.loading));

    try {
      await addSongToPlaylistUsecase(event.playlistId, event.songId);
      emit(state.copyWith(status: PlaylistStatus.success));
      add(FetchUserPlaylistEvent(forceRefresh: true));
    } catch (e) {
      emit(state.copyWith(status: PlaylistStatus.error));
    }
  }

  Future<void> _onRemoveFromPlaylist(
    RemoveFromPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(state.copyWith(status: PlaylistStatus.loading));

    try {
      await removeSongFromPlaylistUsecase(event.playlistId, event.songId);
      emit(state.copyWith(status: PlaylistStatus.success));
      add(FetchUserPlaylistEvent(forceRefresh: true));
      add(FetchPlaylistDetailevent(playlistId: event.playlistId));
    } catch (e) {
      emit(state.copyWith(status: PlaylistStatus.error));
    }
  }
}
