import 'package:sonique/Data/models/playlist_detail_model.dart';
import 'package:sonique/Data/models/playlist_model.dart';
import 'package:sonique/Data/source/playlist_data_repo/playlist_remote_data.dart';
import 'package:sonique/Domain/repository/playlist_repository.dart';

class PlaylistRepositoryImpl extends PlaylistRepository {
  final PlaylistRemoteData playlistRemoteData;

  PlaylistRepositoryImpl({required this.playlistRemoteData});

  @override
  Future<List<PlaylistModel>> getUserPlaylist() async {
    try {
      final res = await playlistRemoteData.getUserPlaylist();
      return res;
    } catch (e) {
      throw Exception('Failed to load user playlists!');
    }
  }

  @override
  Future<PlaylistDetailModel> getPlaylistDetail(int playlistId) async {
    try {
      final res = await playlistRemoteData.getPlaylistDetail(playlistId);
      return res;
    } catch (e) {
      throw Exception('Failed to load user playlists!');
    }
  }

  @override
  Future<void> createPlaylist(String name) async {
    try {
      await playlistRemoteData.createPlaylist(name);
    } catch (e) {
      throw Exception('Failed to create playlist!');
    }
  }

  @override
  Future<void> addToPlaylist(int playlistId, String songId) async {
    try {
      await playlistRemoteData.addToPlaylist(playlistId, songId);
    } catch (e) {
      throw Exception('Failed to add song to playlist!');
    }
  }

  @override
  Future<void> removeFromPlaylist(int playlistId, String songId) async {
    try {
      await playlistRemoteData.removeFromPlaylist(playlistId, songId);
    } catch (e) {
      throw Exception('Failed to add song to playlist!');
    }
  }
}
