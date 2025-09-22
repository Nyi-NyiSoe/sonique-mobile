import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sonique/Data/models/playlist_detail_model.dart';
import 'package:sonique/Data/models/playlist_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class PlaylistRemoteData {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String getUserPlaylistUrl;
  final String getPlaylistDetailUrl;
  final String createPlaylistUrl;
  final String addToPlaylistUrl;
  final String removeFromPlaylistUrl;
  PlaylistRemoteData({required this.client, required this.authLocalDataSource})
    : getUserPlaylistUrl = dotenv.env['GET_USER_PLAYLISTS_URL'] ?? '',
      getPlaylistDetailUrl = dotenv.env['GET_PLAYLIST_DETAIL_URL'] ?? '',
      createPlaylistUrl = dotenv.env['CREATE_PLAYLIST_URL'] ?? '',
      addToPlaylistUrl = dotenv.env['ADD_SONGS_TO_PLAYLIST_URL'] ?? '' ,
      removeFromPlaylistUrl = dotenv.env['REMOVE_SONGS_FROM_PLAYLIST_URL'] ?? ''
      {
    if (getUserPlaylistUrl.isEmpty) {
      throw Exception('GET_USER_PLAYLISTS_URL is not set in .env file');
    }
    if (getPlaylistDetailUrl.isEmpty) {
      throw Exception('GET_PLAYLIST_DETAIL_URL is not set in .env file');
    }

    if (createPlaylistUrl.isEmpty) {
      throw Exception('CREATE_PLAYLIST_URL is not set in .env file');
    }

    if (addToPlaylistUrl.isEmpty) {
      throw Exception('ADD_SONGS_TO_PLAYLIST_URL is not set in .env file');
    }

    if (removeFromPlaylistUrl.isEmpty) {
      throw Exception('REMOVE_SONGS_FROM_PLAYLIST_URL is not set in .env file');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final currentUser = await authLocalDataSource.getUser();
    final token = currentUser.token;
    final refreshToken = currentUser.refreshToken;

    if (token == null || refreshToken == null) {
      throw Exception('Missing access token or refresh token');
    }

    return {
      'Content-Type': 'application/json',
      'Cookie': 'token=$token;refreshToken=$refreshToken',
    };
  }

  //get user's playlist
  Future<List<PlaylistModel>> getUserPlaylist() async {
    try {
      // 1️⃣ Check base URL
      if (getUserPlaylistUrl.isEmpty) {
        throw Exception('GET_USER_PLAYLISTS_URL is not set in .env');
      }

      // 2️⃣ Prepare headers
      final headers = await _getHeaders();
      final user = await authLocalDataSource.getUser();
      print('📡 Fetching playlist for user: ${user.userId}');
      print('🔑 Headers: $headers');

      // 3️⃣ Construct URL safely
      final url = Uri.parse(getUserPlaylistUrl).resolve(user.userId.toString());
      print('🌐 Request URL: $url');

      // 4️⃣ Make HTTP GET request
      final response = await client.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          '❌ Request failed: ${response.statusCode} → ${response.body}',
        );
      }

      // 5️⃣ Parse JSON safely
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Unexpected JSON format (expected Map, got ${decoded.runtimeType})',
        );
      }

      final playlistJson = decoded['data'];
      if (playlistJson == null) {
        throw Exception('Album not found or "data" field is null in response');
      }

      if (playlistJson is! List) {
        throw Exception(
          'Unexpected JSON format for playlist data (expected List, got ${playlistJson.runtimeType})',
        );
      }

      // 7️⃣ Map to model
      return playlistJson
          .map<PlaylistModel>(
            (json) => PlaylistModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stack) {
      print('💥 Error in user playlist: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }

  Future<PlaylistDetailModel> getPlaylistDetail(int playlistId) async {
    try {
      // 1️⃣ Check base URL
      if (getPlaylistDetailUrl.isEmpty) {
        throw Exception('GET_USER_PLAYLISTS_URL is not set in .env');
      }

      // 2️⃣ Prepare headers
      final headers = await _getHeaders();

      print('📡 Fetching playlist for : $playlistId');
      print('🔑 Headers: $headers');

      // 3️⃣ Construct URL safely
      final url = Uri.parse(
        getPlaylistDetailUrl,
      ).resolve(playlistId.toString());
      print('🌐 Request URL: $url');

      // 4️⃣ Make HTTP GET request
      final response = await client.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          '❌ Request failed: ${response.statusCode} → ${response.body}',
        );
      }

      // 5️⃣ Parse JSON safely
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Unexpected JSON format (expected Map, got ${decoded.runtimeType})',
        );
      }

      final playlistJson = decoded['data'];
      if (playlistJson == null) {
        throw Exception('Album not found or "data" field is null in response');
      }

      // 7️⃣ Map to model
      return PlaylistDetailModel.fromJson(decoded);
    } catch (e, stack) {
      print('💥 Error in user playlist: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }

  Future<void> createPlaylist(String name) async {
    try {
      // 1️⃣ Check base URL
      if (createPlaylistUrl.isEmpty) {
        throw Exception('CREATE_PLAYLIST_URL is not set in .env');
      }

      // 2️⃣ Prepare headers
      final headers = await _getHeaders();

      print('🔑 Headers: $headers');

      // 3️⃣ Construct URL safely
      final url = Uri.parse(createPlaylistUrl);
      print('🌐 Request URL: $url');

      final currentUser = await authLocalDataSource.getUser();

      final body = jsonEncode({"userId": currentUser.userId, "name": name});

      // 4️⃣ Make HTTP POST request
      final response = await client.post(url, headers: headers, body: body);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          '❌ Request failed: ${response.statusCode} → ${response.body}',
        );
      }
    } catch (e, stack) {
      print('💥 Error creating user playlist: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }

  Future<void> addToPlaylist(int playlistId, String songId) async {
    try {
      // 1️⃣ Check base URL
      if (addToPlaylistUrl.isEmpty) {
        throw Exception('CREATE_PLAYLIST_URL is not set in .env');
      }

      // 2️⃣ Prepare headers
      final headers = await _getHeaders();

      print('🔑 Headers: $headers');

      // 3️⃣ Construct URL safely
      final url = Uri.parse(addToPlaylistUrl);
      print('🌐 Request URL: $url');

      final currentUser = await authLocalDataSource.getUser();

      final body = jsonEncode({
        "userId": currentUser.userId,
        "playlistId": playlistId,
        "songIds": [songId],
      });

      // 4️⃣ Make HTTP POST request
      final response = await client.patch(url, headers: headers, body: body);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          '❌ Request failed: ${response.statusCode} → ${response.body}',
        );
      }
    } catch (e, stack) {
      print('💥 Error creating user playlist: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }

  Future<void> removeFromPlaylist(int playlistId, String songId) async {
    try {
      // 1️⃣ Check base URL
      if (removeFromPlaylistUrl.isEmpty) {
        throw Exception('REMOVE_SONGS_FROM_PLAYLIST_URLis not set in .env');
      }

      // 2️⃣ Prepare headers
      final headers = await _getHeaders();

      print('🔑 Headers: $headers');

      // 3️⃣ Construct URL safely
      final url = Uri.parse(removeFromPlaylistUrl);
      print('🌐 Request URL: $url');

      final currentUser = await authLocalDataSource.getUser();

      final body = jsonEncode({
        "userId": currentUser.userId,
        "playlistId": playlistId,
        "songIds": [songId],
      });

      // 4️⃣ Make HTTP POST request
      final response = await client.delete(url, headers: headers, body: body);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          '❌ Request failed: ${response.statusCode} → ${response.body}',
        );
      }
    } catch (e, stack) {
      print('💥 Error removing song from playlist: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }
}
