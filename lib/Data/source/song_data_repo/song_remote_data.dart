import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/liked_song_model.dart';
import 'package:sonique/Data/models/song_response_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class SongRemoteData {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;

  final String getSongUrl;
  final String getGenreUrl;
  final String uploadGenreUrl;
  final String uploadSongUrl;
  final String likeSongUrl;
  final String loadLikedSongsUrl;

  SongRemoteData({required this.client, required this.authLocalDataSource})
    : getSongUrl = dotenv.env['GET_ALL_SONGS_URL'] ?? '',
      getGenreUrl = dotenv.env['GET_SONG_GENRES_URL'] ?? '',
      uploadGenreUrl = dotenv.env['UPLOAD_SONG_GENRE_URL'] ?? '',
      uploadSongUrl = dotenv.env['UPLOAD_SONG_URL'] ?? '',
      likeSongUrl = dotenv.env['LIKE_SONG_URL'] ?? '',
      loadLikedSongsUrl = dotenv.env['LOAD_LIKED_SONGS_URL'] ?? '' {
    if (getSongUrl.isEmpty) {
      throw Exception('GET_ALL_SONGS_URL is not set in .env file');
    }
    if (getGenreUrl.isEmpty) {
      throw Exception('GET_SONG_GENRES_URL is not set in .env file');
    }
    if (uploadSongUrl.isEmpty) {
      throw Exception('UPLOAD_SONG_URL is not set in .env file');
    }
    if (loadLikedSongsUrl.isEmpty) {
      throw Exception('LOAD_LIKED_SONG_URL is not set in .env file');
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

  /// 🎵 Get all songs
  Future<SongResponseModel> getAllSongs() async {
    final headers = await _getHeaders();

    try {
      final response = await client.get(
        Uri.parse(getSongUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SongResponseModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch songs: ${response.body}');
      }
    } catch (e) {
      throw Exception('getAllSongs failed: $e');
    }
  }

  /// 🎶 Get more songs with pagination cursor
  Future<SongResponseModel> getMoreSongs(String cursor) async {
    final headers = await _getHeaders();

    try {
      final response = await client.get(
        Uri.parse('$getSongUrl&cursor=$cursor'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SongResponseModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch more songs: ${response.body}');
      }
    } catch (e) {
      throw Exception('getMoreSongs failed: $e');
    }
  }

  /// 🎼 Get all song genres
  Future<List<GenreModel>> getGenre() async {
    final headers = await _getHeaders();

    try {
      final response = await client.get(
        Uri.parse(getGenreUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> list = data['data'];
        return list.map((json) => GenreModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch genres: ${response.body}');
      }
    } catch (e) {
      throw Exception('getGenre failed: $e');
    }
  }

  /// ➕ Upload a new genre
  Future<void> uploadSongGenre(String genreName) async {
    final headers = await _getHeaders();
    final body = jsonEncode({'name': genreName});

    try {
      final response = await client.post(
        Uri.parse(uploadGenreUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload genre: ${response.body}');
      }
      log('Genre uploaded: ${response.body}');
    } catch (e) {
      throw Exception('uploadSongGenre failed: $e');
    }
  }

  /// ⬆️ Upload a new song with audio + cover image
  Future<void> uploadSong(
    XFile audioFile,
    XFile coverImage,
    String genreId,
    String title,
  ) async {
    final currentUser = await authLocalDataSource.getUser();
    final headers = await _getHeaders();

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(uploadSongUrl))
            ..headers.addAll(headers)
            ..fields['genreId'] = genreId
            ..fields['title'] = title;

      if (currentUser.isArtist) {
        request.fields['artistId'] = currentUser.userId.toString();
      }

      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('coverImage', coverImage.path),
      );

      final response = await request.send();

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to upload song, status: ${response.statusCode}',
        );
      }

      log('Song uploaded successfully');
    } catch (e) {
      throw Exception('uploadSong failed: $e');
    }
  }

  Future<void> likeASong(String songId) async {
    final currentUser = await authLocalDataSource.getUser();
    final headers = await _getHeaders();
    final body = jsonEncode({"songId": songId, "userId": currentUser.userId});
    try {
      final response = await client.post(
        Uri.parse(likeSongUrl),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception(
            'Failed to like song, status: ${response.statusCode}',
          );
        }

        log('Liked song successfully');
      }
    } catch (e) {
      throw Exception('liking failed: $e');
    }
  }

  Future<List<LikedSongModel>> loadLikedSongs() async {
    final currentUser = await authLocalDataSource.getUser();
    final headers = await _getHeaders();
    final url = Uri.parse(
      loadLikedSongsUrl,
    ).replace(queryParameters: {"userId": currentUser.userId.toString()});
    try {
      final res = await client.get(url, headers: headers);
      log(res.body);
      if (res.statusCode == 200) {
      
        return (jsonDecode(res.body)['data'] as List)
            .map((json) => LikedSongModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed loading liked songs');
      }
    } catch (e) {
      throw Exception('Failed loading liked songs: $e');
    }
  }
}
