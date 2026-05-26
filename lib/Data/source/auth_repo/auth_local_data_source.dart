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
    final jsonString = jsonEncode(user.toMap());
    //print("✅ Saving user JSON: $jsonString");
    await prefs.setString(_userKey, jsonString);
  }

  Future<UserModel> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    //print('🔍 Raw userJson from SharedPreferences: $userJson');

    if (userJson == null) {
      throw Exception("User not found in local storage");
    }

    try {
      final userMap = jsonDecode(userJson);

      if (userMap is String) {
        //print("⚠️ Double-encoded JSON detected. Decoding again...");
        final decodedUserMap = jsonDecode(userMap);

        final token = decodedUserMap['token'];
        final refreshToken = decodedUserMap['refreshToken'];
        return UserModel.fromJson(
          decodedUserMap,
          token: token,
          refreshToken: refreshToken,
        );
      }

      return UserModel.fromJson(userMap);
    } catch (e) {
      throw Exception("❌ Failed to decode user JSON: $e");
    }
  }

  // Delete user
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
