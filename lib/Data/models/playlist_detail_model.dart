import 'package:sonique/Data/models/artist_model.dart';
import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Domain/entities/playlist_detail.dart';

class PlaylistDetailModel extends PlaylistDetail {
  PlaylistDetailModel({
    super.id,
    super.createdAt,
    super.name,
    super.playlist_coverImageUrl,
    super.songs,
  });

  factory PlaylistDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final songsJson = data['songs'] as List<dynamic>?;

    final songsList =
        songsJson
            ?.map((songJson) {
              if (songJson is Map<String, dynamic>) {
                final artistJson = songJson['artist'] as Map<String, dynamic>?;

                return SongModel(
                  artist: ArtistModel(
                    artistId: artistJson?['artistId'] ?? 0,
                    name: artistJson?['name'] ?? '',
                    username: artistJson?['username'] ?? '',
                  ),
                  audioUrl: songJson['audioUrl'] ?? songJson['fileUrl'] ?? '',
                  coverImageUrl: songJson['coverImageUrl'] ?? '',
                  created_at:
                      songJson['created_at'] ?? songJson['create_at'] ?? '',
                  duration: (songJson['duration'] as num?)?.toDouble() ?? 0.0,
                  genre: songJson['genre'] ?? 0,
                  id: songJson['id'] ?? '',
                  title: songJson['title'] ?? '',
                );
              }
              return null;
            })
            .whereType<SongModel>()
            .toList() ??
        [];

    return PlaylistDetailModel(
      id: data['id'],
      name: data['name'],
      songs: songsList,
      createdAt: data['created_at'],
      playlist_coverImageUrl: data['playlist_coverImageUrl']
    );
  }
}
