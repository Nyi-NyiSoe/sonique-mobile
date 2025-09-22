import 'package:sonique/Data/models/song_model.dart';

class PlaylistDetail {
  final int? id;
  final String? createdAt;
  final String? name;
  final String? playlist_coverImageUrl;
  final List<SongModel>? songs;

  PlaylistDetail({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.songs,
    required this.playlist_coverImageUrl,
  });
}
