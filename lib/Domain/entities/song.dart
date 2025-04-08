import 'package:sonique/Data/models/artist_model.dart';

class Song {
  final ArtistModel artist;
  final String audioUrl;
  final String coverImageUrl;
  final String created_at;
  final double duration;
  final int genre;
  final String id;
  final String title;

  Song({
    required this.artist,
    required this.audioUrl,
    required this.coverImageUrl,
    required this.created_at,
    required this.duration,
    required this.genre,
    required this.id,
    required this.title,
  });

  @override
  String toString() {
    return 'Song{ artist: $artist, audioUrl: $audioUrl, coverImageUrl: $coverImageUrl, created_at: $created_at, duration: $duration, genre: $genre, id: $id, title: $title}';
  }
}
