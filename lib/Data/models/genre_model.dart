import 'dart:convert';

import 'package:sonique/Domain/entities/genre.dart';

class GenreModel extends Genre {
  GenreModel({
    required super.id,
    required super.name,
    required super.created_at,
    required super.updated_at,
    required super.deleted_at,
  });
  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] ?? 0, // Handle null values
      name: json['name'] ?? "",
      created_at: json['created_at'] ?? "",
      updated_at: json['updated_at'] ?? "",
      deleted_at: json['deleted_at'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': created_at,
      'updated_at': updated_at,
      'deleted_at': deleted_at,
    };
  }

  String toJson() => json.encode(toMap());
}
