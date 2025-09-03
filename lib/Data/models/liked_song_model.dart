import 'package:sonique/Data/models/artist_model.dart';
import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Domain/entities/likedSong.dart';

class LikedSongModel extends LikedSong {
  LikedSongModel({
    required super.artist,
    required super.coverImageUrl,
    required super.duration,
    required super.fileUrl,
    required super.genre,
    required super.id,
    required super.title,
  });

  factory LikedSongModel.fromJson(Map<String, dynamic> json) {
  return LikedSongModel(
    artist: ArtistModel.fromJson(json['artist'] as Map<String, dynamic>),
    coverImageUrl: json['coverImageUrl'] ?? "",
    duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
    fileUrl: json['fileUrl'] ?? "",
    genre: GenreModel.fromJson(json['Genre'] as Map<String, dynamic>),
    id: json['id'] ?? "",
    title: json['title'] ?? "",
  );
}

}
