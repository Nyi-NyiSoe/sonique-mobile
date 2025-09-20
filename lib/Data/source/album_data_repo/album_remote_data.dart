import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sonique/Data/models/album_detail_model.dart';
import 'package:sonique/Data/models/album_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class AlbumRemoteData {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String getAllAlbumsUrl;
  final String getAlbumDetailUrl;

  AlbumRemoteData({required this.client, required this.authLocalDataSource})
    : getAllAlbumsUrl = dotenv.env['GET_ALL_ALBUMS_URL'] ?? '',
      getAlbumDetailUrl = dotenv.env['GET_ALBUM_DETAIL_URL'] ?? '' {
    if (getAllAlbumsUrl.isEmpty) {
      throw Exception('GET_ALL_ALBUMS_URL is not set in .env file');
    }
    if (getAlbumDetailUrl.isEmpty) {
      throw Exception('GET_ALBUM_DETAIL_URL is not set in .env file');
    }
  }

  /// 🔑 Helper: Build authenticated headers
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

  //get all albums
  Future<List<AlbumModel>> getAllAlbums() async {
    try {
      final headers = await _getHeaders();
      print('📡 Fetching albums from: $getAllAlbumsUrl');
      print('🔑 Headers: $headers');

      final response = await client.get(
        Uri.parse(getAllAlbumsUrl),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data is! Map<String, dynamic>) {
            throw Exception(
              'Unexpected format (expected Map, got ${data.runtimeType})',
            );
          }

          final albumsJson = data['data'] as List<dynamic>?; // 👈 use "data"
          if (albumsJson == null) {
            throw Exception('Response missing "data" field');
          }
          return albumsJson
              .map(
                (albumJson) =>
                    AlbumModel.fromJson(albumJson as Map<String, dynamic>),
              )
              .toList();
        } catch (jsonError) {
          throw Exception('❌ JSON parsing failed: $jsonError');
        }
      } else {
        throw Exception(
          '❌ Request failed: ${response.statusCode} → ${response.body}',
        );
      }
    } catch (e, stack) {
      print('💥 Error in getAllAlbums: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc with context
    }
  }

  Future<AlbumDetailModel> getAlbumDetail(int albumId) async {
    try {
      // 1️⃣ Check base URL
      if (getAlbumDetailUrl.isEmpty) {
        throw Exception('GET_ALBUM_DETAIL_URL is not set in .env');
      }

      // 2️⃣ Prepare headers
      final headers = await _getHeaders();
      print('📡 Fetching album detail for ID: $albumId');
      print('🔑 Headers: $headers');

      // 3️⃣ Construct URL safely
      final url = Uri.parse(getAlbumDetailUrl).resolve(albumId.toString());
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

      final albumJson = decoded['data'];
      if (albumJson == null) {
        throw Exception('Album not found or "data" field is null in response');
      }

      if (albumJson is! Map<String, dynamic>) {
        throw Exception(
          'Unexpected JSON format for album detail (expected Map, got ${albumJson.runtimeType})',
        );
      }

      

      // 7️⃣ Map to model
      return AlbumDetailModel.fromJson(albumJson);
    } catch (e, stack) {
      print('💥 Error in getAlbumDetail: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }
}
