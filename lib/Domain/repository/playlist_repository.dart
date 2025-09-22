import 'package:sonique/Data/models/playlist_detail_model.dart';
import 'package:sonique/Data/models/playlist_model.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistModel>> getUserPlaylist();
  Future<PlaylistDetailModel> getPlaylistDetail(int playlistId);
  Future<void> createPlaylist(String name);
  Future<void> addToPlaylist(int playlistId,String songId);
  Future<void> removeFromPlaylist(int playlistId,String songId);
}