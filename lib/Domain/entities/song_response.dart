import 'package:sonique/Data/models/song_model.dart';

class SongResponse {
  final bool hasMore;
  final String nextCursor;
  final List<SongModel> songs;
  final String status;

  SongResponse({
    required this.hasMore,
    required this.nextCursor,
    required this.songs,
    required this.status,
  });

  @override
  String toString() {
    return 'SongResponse{hasMore: $hasMore, nextCursor: $nextCursor, songs: $songs, status: $status}';
  }
}
