import 'package:sonique/Data/models/artist_model.dart';
import 'package:sonique/Data/models/genre_model.dart';

class LikedSong {
  final ArtistModel artist;
  final String coverImageUrl;
  final double duration;
  final String fileUrl;
  final GenreModel genre;
  final String id;
  final String title;

  LikedSong({
    required this.artist,
    required this.coverImageUrl,
    required this.duration,
    required this.fileUrl,
    required this.genre,
    required this.id,
    required this.title,
  });

  @override
  String toString() {
    return 'Likedsong(title: $title, artist: ${artist.toString()}, genre: ${genre.toString()}, id: $id, coverImageUrl: $coverImageUrl, duration: $duration, fileUrl: $fileUrl)';
  }
}
