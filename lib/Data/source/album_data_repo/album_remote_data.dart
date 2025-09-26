import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/core/api_client.dart';
import 'package:sonique/Data/models/album_detail_model.dart';
import 'package:sonique/Data/models/album_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class AlbumRemoteData {
  final ApiClient client;
  final AuthLocalDataSource authLocalDataSource;
  final String getAllAlbumsUrl;
  final String getAlbumDetailUrl;
  final String getAlbumByArtistIdUrl;
  final String createAlbumUrl;
  final String addSongsToAlbumUrl;
  final String removeSongFromAlbumUrl;

  AlbumRemoteData({required this.client, required this.authLocalDataSource})
    : getAllAlbumsUrl = dotenv.env['GET_ALL_ALBUMS_URL'] ?? '',
      getAlbumDetailUrl = dotenv.env['GET_ALBUM_DETAIL_URL'] ?? '',
      getAlbumByArtistIdUrl = dotenv.env['GET_ALBUM_ARTISTID_URL'] ?? '',
      createAlbumUrl = dotenv.env['CREATE_ALBUM_URL'] ?? '',
      addSongsToAlbumUrl = dotenv.env['ADD_SONGS_TO_ALBUM_URL'] ?? '',
      removeSongFromAlbumUrl = dotenv.env['REMOVE_SONGS_FROM_ALBUM_URL'] ?? '' {
    if (getAllAlbumsUrl.isEmpty) {
      throw Exception('GET_ALL_ALBUMS_URL is not set in .env file');
    }
    if (getAlbumDetailUrl.isEmpty) {
      throw Exception('GET_ALBUM_DETAIL_URL is not set in .env file');
    }
    if (getAlbumByArtistIdUrl.isEmpty) {
      throw Exception('GET_ALBUM_ARTISTID_URL is not set in .env file');
    }
    if (createAlbumUrl.isEmpty) {
      throw Exception('CREATE_ALBUM_URL is not set in .env file');
    }
    if (addSongsToAlbumUrl.isEmpty) {
      throw Exception('ADD_SONGS_TO_ALBUM_URL is not set in .env file');
    }
    if (removeSongFromAlbumUrl.isEmpty) {
      throw Exception('REMOVE_SONGS_FROM_ALBUM_URL is not set in .env file');
    }
  }

  /// 🔑 Helper: Build authenticated headers
  Future<Map<String, String>> _getHeaders() async {
    final currentUser = await authLocalDataSource.getUser();

    return {'Content-Type': 'application/json'};
  }

  //get all albums
  Future<List<AlbumModel>> getAllAlbums() async {
    try {
      final headers = await _getHeaders();
      print('📡 Fetching albums from: $getAllAlbumsUrl');
      print('🔑 Headers: $headers');

      final response = await client.get(
       getAllAlbumsUrl,
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
      final url = '$getAlbumDetailUrl/$albumId';
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

  Future<List<AlbumModel>> getAlbumByArtistId(int? artistId) async {
    try {
      // 1️⃣ Check base URL
      if (getAlbumByArtistIdUrl.isEmpty) {
        throw Exception('GET_ALBUM_DETAIL_URL is not set in .env');
      }

      // 2️⃣ Prepare headers
      final headers = await _getHeaders();
      print('📡 Fetching album detail for ID: $artistId');
      print('🔑 Headers: $headers');
      final currentUser = await authLocalDataSource.getUser();
      final defaultId = currentUser.userId;

      // 3️⃣ Construct URL safely
      final url = '$getAlbumByArtistIdUrl/${artistId ?? defaultId}';
      print('🌐 Request URL: $url');

      // 4️⃣ Make HTTP GET request
      final response = await client.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body} $artistId');

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

      final albumsJson = decoded['data'];
      if (albumsJson == null) {
        throw Exception('Albums not found or "data" field is null in response');
      }

      if (albumsJson is! List<dynamic>) {
        throw Exception(
          'Unexpected JSON format for albums (expected List, got ${albumsJson.runtimeType})',
        );
      }

      // 7️⃣ Map to model list
      return albumsJson
          .map(
            (albumJson) =>
                AlbumModel.fromJson(albumJson as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stack) {
      print('💥 Error in getAlbumByArtistId: $e');
      print('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }

  // Add this import at the top of your file:
  // import 'package:http_parser/http_parser.dart';

  Future<void> createAlbum(
    String name,
    XFile coverImage,
    String description,
  ) async {
    final currentUser = await authLocalDataSource.getUser();
    try {
      // 1️⃣ Check URLs
      if (createAlbumUrl.isEmpty) {
        throw Exception('CREATE_ALBUM_URL is not set in .env');
      }
      // 2️⃣ Check file exists
      final file = File(coverImage.path);
      final exists = await file.exists();
      if (!exists) {
        throw Exception(
          'Cover image file does not exist at path: ${coverImage.path}',
        );
      }
      log('Cover image exists: $exists');

      // 3️⃣ Prepare headers (EXCLUDE Content-Type for Multipart)
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // 🔥 Remove Content-Type for multipart
      log('Headers: $headers');

      // 4️⃣ Construct Multipart request
      final request =
          http.MultipartRequest('POST', Uri.parse(createAlbumUrl))
            ..headers.addAll(headers)
            ..fields['artistId'] = currentUser.userId.toString()
            ..fields['name'] = name
            ..fields['description'] = description;

      // 5️⃣ Attach file with explicit MIME type and proper filename
      final fileBytes = await File(coverImage.path).readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'coverImage',
          fileBytes,
          filename: 'cover.jpeg',
          contentType: MediaType(
            'image',
            'jpeg',
          ), // Requires http_parser import
        ),
      );

      // 6️⃣ Debug print everything
      log('--- Sending Multipart Request ---');
      log('Fields: ${request.fields}');
      log(
        'Files: ${request.files.map((f) => '${f.filename} (${f.contentType})').toList()}',
      );
      log('URL: $createAlbumUrl');

      // 7️⃣ Send request
      final response = await request.send();

      // 8️⃣ Read response body
      final respStr = await response.stream.bytesToString();
      log('Response status: ${response.statusCode}');
      log('Response body: $respStr');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to create album, status: ${response.statusCode}, body: $respStr',
        );
      }
      log('✅ Album created successfully');
    } catch (e, stack) {
      log('💥 Error in createAlbum: $e');
      log('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }

  Future<void> addSongsToAlbum(Set<String> songIds, int albumId) async {
    try {
      // 1️⃣ Check URLs
      if (addSongsToAlbumUrl.isEmpty) {
        throw Exception('ADD_SONGS_TO_ALBUM_URL is not set in .env');
      }

      // 3️⃣ Prepare headers (EXCLUDE Content-Type for Multipart)
      final headers = await _getHeaders();

      log('Headers: $headers');
      final body = jsonEncode({
        "albumId": albumId,
        "songIds": songIds.toList(), // ✅ convert Set to List
      });

      final response = await client.patch(
        addSongsToAlbumUrl,
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to add songs to album, status: ${response.statusCode}, body: ${response.body}',
        );
      }
      log('✅ Songs added successfully');
    } catch (e, stack) {
      log('💥 Error adding songs to album: $e');
      log('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }

  Future<void> removeSongFromAlbum(String songIds, int albumId) async {
    try {
      // 1️⃣ Check URLs
      if (removeSongFromAlbumUrl.isEmpty) {
        throw Exception('REMOVE_SONGS_FROM_ALBUM_URL is not set in .env');
      }

      // 3️⃣ Prepare headers (EXCLUDE Content-Type for Multipart)
      final headers = await _getHeaders();

      log('Headers: $headers');
      final body = jsonEncode({
        "albumId": albumId,
        "songIds": [songIds],
      });

      final response = await client.delete(
        removeSongFromAlbumUrl,
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to remove songs to album, status: ${response.statusCode}, body: ${response.body}',
        );
      }
      log('✅ Songs remove successfully');
    } catch (e, stack) {
      log('💥 Error remove songs from album: $e');
      log('📜 Stack trace: $stack');
      rethrow; // propagate to Bloc
    }
  }
}
