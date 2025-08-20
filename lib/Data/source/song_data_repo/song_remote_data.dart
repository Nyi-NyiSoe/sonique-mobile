import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/song_response_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class SongRemoteData {
  final http.Client client;
  late String getSongUrl;
  late String getSongByIdUrl;
  late String getGenreUrl;
  late String uploadGenreUrl;
  late String uploadSongUrl;
  final AuthLocalDataSource authLocalDataSource;

  SongRemoteData({required this.client, required this.authLocalDataSource}) {
    getSongUrl =
        dotenv.env['GET_ALL_SONGS_URL'] ?? ''; // Replace with your actual URL

    getGenreUrl = dotenv.env['GET_SONG_GENRES_URL'] ?? '';
    uploadGenreUrl = dotenv.env['UPLOAD_SONG_GENRE_URL'] ?? '';

    uploadSongUrl = dotenv.env['UPLOAD_SONG_URL'] ?? '';
    if (getSongUrl.isEmpty) {
      throw Exception('API URL is not set in .env file');
    }

    if (getGenreUrl.isEmpty) {
      throw Exception('genre URL is not set in .env file');
    }

    if (uploadSongUrl.isEmpty) {
      throw Exception('song URL is not set in .env file');
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

  Future<List<GenreModel>> getGenre() async {
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
    try {
      final response = await client.get(
        Uri.parse(getGenreUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> dataList = data['data'];
        return dataList.map((json) => GenreModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to turn into model ${response.body}');
      }
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  Future<void> uploadSongGenre(String genreName) async {
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
    final body = jsonEncode({'name': genreName});

    try {
      final response = await client.post(
        Uri.parse(uploadGenreUrl),
        headers: headers,
        body: body,
      );

      log(response.body);
    } catch (e) {
      throw Exception('Error uploading gnere; $e');
    }
  }

  Future<void> uploadSong(
    XFile audioFile,
    XFile coverImage,
    String genreId,
    String title,
  ) async {
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

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$uploadSongUrl'),
      );
      request.headers.addAll(headers);
      if (currentUser.isArtist) {
        request.fields['artistId'] = currentUser.userId.toString();
      }
      request.fields['genreId'] = genreId;
      request.fields['title'] = title;

      //add audio file
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

      //add cover image
      request.files.add(
        await http.MultipartFile.fromPath('coverImage', coverImage.path),
      );

      //send req
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Success');
        log(response.toString());
      } else {
        log(response.statusCode.toString());
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
