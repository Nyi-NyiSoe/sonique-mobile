import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class UserRemoteData {
  final http.Client client;
  late String getUserUrl;
  late String updateUserUrl;
  final AuthLocalDataSource authLocalDataSource;
  // This class is responsible for fetching user data from a remote source.
  // It could be an API or a database.
  // For now, we will just create a placeholder method to simulate fetching user data.
  UserRemoteData({required this.client, required this.authLocalDataSource}) {
    getUserUrl =
        dotenv.env['GET_USER_DETAIL_URL'] ?? ''; // Replace with your actual URL
    updateUserUrl =
        dotenv.env['UPDATE_USER_DETAIL_URL'] ??
        ''; // Replace with your actual URL

    if (getUserUrl.isEmpty || updateUserUrl.isEmpty) {
      throw Exception('API URL is not set in .env file');
    }
  }
  

  Future<UserModel> fetchUserData() async {
    final currentUser = await authLocalDataSource.getUser();
    final userId = currentUser.userId.toString();
    final refreshToken = currentUser.refreshToken;
    final token = currentUser.token;

    if (refreshToken == null || token == null) {
      throw Exception('Refresh token or access token is missing');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'token=$token;refreshToken=$refreshToken',
    };
    late final http.Response response;
    try {
      response = await client.get(
        Uri.parse('$getUserUrl/$userId'),
        headers: headers,
      );

      log('User data response: ${response.body}');
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
