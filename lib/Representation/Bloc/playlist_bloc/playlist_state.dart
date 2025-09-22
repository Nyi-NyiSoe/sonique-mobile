import 'package:sonique/Data/models/playlist_detail_model.dart';
import 'package:sonique/Data/models/playlist_model.dart';

enum PlaylistStatus { initial, loading, success, error }

class PlaylistState {
  final PlaylistStatus status;
  final List<PlaylistModel> playlists;
  final PlaylistDetailModel? selectedPlaylist;
  final String? message;

  const PlaylistState({
    this.status = PlaylistStatus.initial,
    this.playlists = const [],
    this.selectedPlaylist,
    this.message,
  });

  PlaylistState copyWith({
    PlaylistStatus? status,
    List<PlaylistModel>? playlists,
    PlaylistDetailModel? selectedPlaylist,
    String? message,
  }) {
    return PlaylistState(
      status: status ?? this.status,
      playlists: playlists ?? this.playlists,
      selectedPlaylist: selectedPlaylist,
      message: message,
    );
  }
}
