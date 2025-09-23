import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sonique/Data/models/display_artist_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class ArtistRemoteData {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String getAllArtistUrl;

  ArtistRemoteData({required this.client, required this.authLocalDataSource})
    : getAllArtistUrl = dotenv.env['GET_ALL_ARTISTS_URL'] ?? '' {
    if (getAllArtistUrl.isEmpty) {
      throw Exception('GET_ALL_ARTISTS_URL is not set in .env file');
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

  Future<List<DisplayArtistModel>> getAllArtist() async {
    try {
      final headers = await _getHeaders();
      print('📡 Fetching albums from: $getAllArtistUrl');
      print('🔑 Headers: $headers');

      final response = await client.get(
        Uri.parse(getAllArtistUrl),
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

          final artistJson = data['data']['artists'] as List<dynamic>?; // 👈 use "data"
          if (artistJson == null) {
            throw Exception('Response missing "data" field');
          }
          return artistJson
              .map(
                (json) =>
                    DisplayArtistModel.fromJson(json as Map<String, dynamic>),
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
      print('💥 Error in get all artist: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc with context
    }
  }


}
