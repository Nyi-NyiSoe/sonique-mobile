import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonique/Data/models/user_model.dart';

class AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _userKey = "user_data";

  AuthLocalDataSource({required this.sharedPreferences});
  // Save user
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) {
      print("No user data found.");
      return null;
    }

    try {
      print("Stored user JSON: $userJson");

      // Try decoding once
      final userMap = jsonDecode(userJson);

      // If userMap is still a string, decode again
      if (userMap is String) {
        print("Double-encoded JSON detected. Decoding again...");
        return UserModel.fromJson(jsonDecode(userMap));
      }

      return UserModel.fromJson(userMap);
    } catch (e) {
      print("Error decoding user JSON: $e");
      return null;
    }
  }

  // Delete user
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
