import 'dart:convert';

import 'package:sonique/Domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.username,
    required super.createdAt,
    required super.isArtist,
    required super.total_songs,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        userId: json['userId'] ?? 0, // Handle null values
        firstName: json['firstName'] ?? "",
        lastName: json['lastName'] ?? "",
        email: json['email'] ?? "",
        username: json['username'] ?? "",
        createdAt: json['createdAt'] ?? DateTime.now().toString(),
        isArtist: json['isArtist'] ?? false,
        total_songs: json['total_songs'] ?? 0,
      );
    } catch (e, stacktrace) {
      print("Error parsing UserModel: $e\n$stacktrace");
      throw Exception("Failed to parse user data");
    }
  }
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'createdAt': createdAt,
      'isArtist': isArtist,
      'totalSongs': total_songs,
    };
  }

  String toJson() => json.encode(toMap());
}
