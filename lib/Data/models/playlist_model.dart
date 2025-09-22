import 'package:sonique/Domain/entities/playList.dart';

class PlaylistModel extends Playlist {
  PlaylistModel({
    super.id,
    super.createdAt,
    super.deletedAt,
    super.name,
    super.userId,
    super.updatedAt,
    super.totalSongs,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      userId: json['userId'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'] ?? '',
      totalSongs: json['total_songs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
