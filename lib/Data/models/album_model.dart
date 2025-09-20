import 'package:sonique/Domain/entities/album.dart';

class AlbumModel extends Album {
  AlbumModel({
    super.artistId,
    super.coverImageUrl,
    super.created_at,
    super.description,
    super.id,
    super.name,
    super.updated_at,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      artistId: json['artistId'] ?? 0,
      coverImageUrl: json['coverImageUrl'] ?? "",
      created_at: json['created_at'] ?? "",
      description: json['description'] ?? "",
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      updated_at: json['updated_at'] ?? "",
    );
  }
}
