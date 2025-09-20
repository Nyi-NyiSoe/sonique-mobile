import 'package:sonique/Data/models/artist_model.dart';
import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Domain/entities/album.dart';
import 'package:sonique/Domain/entities/song.dart';

class AlbumDetailModel extends Album {
  final List<Song> songs;

  AlbumDetailModel({
    required super.artistId,
    required super.coverImageUrl,
    required super.created_at,
    required super.description,
    required super.id,
    required super.name,
    required super.updated_at,
    required this.songs,
  });

  factory AlbumDetailModel.fromJson(Map<String, dynamic> json) {
    final albumArtistId = json['artistId'] as int? ?? 0;

    final songsJson = json['songs'] as List<dynamic>?;

    final songsList =
        songsJson
            ?.map((songJson) {
              if (songJson is Map<String, dynamic>) {
                // Create SongModel, inject ArtistModel with album's artistId
                return SongModel(
                  artist: ArtistModel(
                    artistId: albumArtistId,
                    name: '', // no name available
                    username: '', // no username available
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

    return AlbumDetailModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      description: json['description'] as String? ?? '',
      songs: songsList,
      artistId: albumArtistId,
    );
  }
}
