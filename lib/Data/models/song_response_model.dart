import 'dart:convert';

import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Domain/entities/song_response.dart';

class SongResponseModel extends SongResponse {
  SongResponseModel({
    required super.hasMore,
    required super.nextCursor,
    required super.songs,
    required super.status,
  });

  factory SongResponseModel.fromJson(Map<String, dynamic> json) {
    return SongResponseModel(
      hasMore: json['hasMore'] ?? false,
      nextCursor: json['nextCursor'] ?? "",
      songs: List<SongModel>.from(
        json['songs']?.map((x) => SongModel.fromJson(x)) ?? [],
      ),
      status: json['status'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasMore': hasMore,
      'nextCursor': nextCursor,
      'songs': songs,
      'status': status,
    };
  }

  String toJson() => json.encode(toMap());
}
