import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sonique/Data/models/song_response_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class SongRemoteData {
  final http.Client client;
  late String getSongUrl;
  late String getSongByIdUrl;
  final AuthLocalDataSource authLocalDataSource;

  SongRemoteData({required this.client, required this.authLocalDataSource}) {
    getSongUrl =
        dotenv.env['GET_ALL_SONGS_URL'] ?? ''; // Replace with your actual URL

    if (getSongUrl.isEmpty) {
      throw Exception('API URL is not set in .env file');
    }
  }
  Future<SongResponseModel> getAllSongs() async {
    final currentUser = await authLocalDataSource.getUser();
    final refreshToken = currentUser.refreshToken;
    final token = currentUser.token;

    if (refreshToken == null || token == null) {
      throw Exception('Refresh token or access token is missing');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'token=$token;refreshToken=$refreshToken',
    };

    //log('Sending headers: $headers');

    try {
      final response = await client.get(
        Uri.parse(getSongUrl),
        headers: headers,
      );
      //log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SongResponseModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch songs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

   Future<SongResponseModel> getMoreSongs(String cursor) async {
    final currentUser = await authLocalDataSource.getUser();
    final refreshToken = currentUser.refreshToken;
    final token = currentUser.token;

    if (refreshToken == null || token == null) {
      throw Exception('Refresh token or access token is missing');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'token=$token;refreshToken=$refreshToken',
    };

    //log('Sending headers: $headers');

    try {
      final response = await client.get(
        Uri.parse('$getSongUrl&cursor=$cursor'),
        headers: headers,
      );
      //log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SongResponseModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch songs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  
}
