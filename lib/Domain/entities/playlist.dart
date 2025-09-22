class Playlist {
  final int? id;
  final String? name;
  final int?  totalSongs;
  final String?  createdAt;
  final String?  updatedAt;
  final String? deletedAt;
  final int?  userId;

  Playlist({
    required this.id,
    required this.name,
    required this.totalSongs,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
  });
}
