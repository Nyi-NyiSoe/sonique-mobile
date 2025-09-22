import 'package:sonique/Domain/entities/artist.dart';

class DisplayArtistModel extends Artist {
  final String? profile_image;
  final int? totalSongs;
  final String? bio;

  DisplayArtistModel({
    required super.artistId,
    required super.username,
    required super.name,
    this.profile_image,
    this.totalSongs,
    this.bio,
  });

  factory DisplayArtistModel.fromJson(Map<String, dynamic> json) {
    return DisplayArtistModel(
      artistId: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      profile_image: json['profile_image'] ?? '',
      totalSongs: json['total_songs'] ?? 0,
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': artistId,
      'username': username,
      'name': name,
      'profile_image': profile_image,
      'total_songs': totalSongs,
      'bio': bio,
    };
  }
}
