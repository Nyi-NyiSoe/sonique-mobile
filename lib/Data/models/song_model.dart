import 'dart:convert';

import 'package:sonique/Data/models/artist_model.dart';
import 'package:sonique/Domain/entities/song.dart';

class SongModel extends Song {
  SongModel({
    required super.artist,
    required super.audioUrl,
    required super.coverImageUrl,
    required super.created_at,
    required super.duration,
    required super.genre,
    required super.id,
    required super.title,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      artist: ArtistModel.fromJson(
        json['artist'] ?? json['artistId'] ?? 0
      ),
      audioUrl: json['audioUrl'] ?? json['fileUrl'] ?? "",
      coverImageUrl: json['coverImageUrl'] ?? "",
      created_at: json['created_at'] ?? "",
      duration: json['duration'] ?? 0.0,
      genre: json['genre'] ?? 0,
      id: json['id'] ?? "",
      title: json['title'] ?? "",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'artist': artist.toJson(),
      'audioUrl': audioUrl,
      'coverImageUrl': coverImageUrl,
      'created_at': created_at,
      'duration': duration,
      'genre': genre,
      'id': id,
      'title': title,
    };
  }

  String toJson() => json.encode(toMap());
}
