import 'dart:convert';

import 'package:sonique/Domain/entities/artist.dart';

class ArtistModel extends Artist {
  ArtistModel({
    required super.artistId,
    required super.username,
    required super.name,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      artistId: json['artistId'] ?? 0, // Handle null values
      username: json['username'] ?? "",
      name: json['name'] ?? "",
    );
  }
  Map<String, dynamic> toMap() {
    return {'artistId': artistId, 'username': username, 'name': name};
  }

  String toJson() => json.encode(toMap());
}
