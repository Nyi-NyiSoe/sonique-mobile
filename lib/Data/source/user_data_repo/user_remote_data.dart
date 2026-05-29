import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/core/api_client.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';

class UserRemoteData {
  final ApiClient apiClient;
  late String getUserUrl;
  late String updateUserUrl;
  late String activateArtistUrl;
  late String deactivateArtistUrl;
  late String uploadGenreUrl;
  final AuthLocalDataSource authLocalDataSource;
  // This class is responsible for fetching user data from a remote source.
  // It could be an API or a database.
  // For now, we will just create a placeholder method to simulate fetching user data.
  UserRemoteData({required this.apiClient, required this.authLocalDataSource}) {
    getUserUrl =
        dotenv.env['GET_USER_DETAIL_URL'] ?? ''; // Replace with your actual URL
    updateUserUrl =
        dotenv.env['UPDATE_USER_DETAIL_URL'] ??
        ''; // Replace with your actual URL
    activateArtistUrl = dotenv.env['ACTIVATE_ARTIST_URL'] ?? '';
    deactivateArtistUrl = dotenv.env['DEACTIVATE_ARTIST_URL'] ?? '';

    if (getUserUrl.isEmpty || updateUserUrl.isEmpty) {
      throw Exception('API URL is not set in .env file');
    }
  }

  Future<UserModel> fetchUserData() async {
    final currentUser = await authLocalDataSource.getUser();
    final userId = currentUser.userId.toString();

    final headers = {'Content-Type': 'application/json'};
    late final http.Response response;
    try {
      response = await apiClient.get('$getUserUrl/$userId', headers: headers);

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

  Future<String> updateUserImage(XFile? profile_image) async {
    final currentUser = await authLocalDataSource.getUser();
    final userId = currentUser.userId.toString();
    final token = currentUser.token?.trim();
    final refreshToken = currentUser.refreshToken?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('Access token is missing');
    }

    final headers = {
      if (refreshToken != null && refreshToken.isNotEmpty)
        'Cookie': 'token=$token;refreshToken=$refreshToken',
      'Authorization': 'Bearer $token',
    };

    try {
      //final request = http.MultipartRequest(
      //  'PATCH',
      //  Uri.parse('$updateUserUrl/$userId'),
      // );
      // request.headers.addAll(headers);
      // request.files.add(
      //   await http.MultipartFile.fromPath('profile_image', profile_image!.path),
      // );

      final response = await apiClient.sendMultipart(
        endpoint: "$updateUserUrl/$userId",
        files: {'profile_image': profile_image!.path},
        method: 'PATCH',
        headers: headers,
      );
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return 'Profile image updated successfully';
      } else {
        throw Exception('Failed to update profile image: $responseBody');
      }
    } catch (e) {
      throw Exception('Error updating profile image: $e');
    }
  }

  Future<void> updateUserDetails(
    String? bio,
    String? firstName,
    String? lastName,
    String? username,
  ) async {
    final currentUser = await authLocalDataSource.getUser();
    final userId = currentUser.userId.toString();

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'bio': bio ?? currentUser.bio,
      'firstName': firstName ?? currentUser.firstName,
      'lastName': lastName ?? currentUser.lastName,
      'username': username ?? currentUser.username,
    });

    try {
      final response = await apiClient.patch(
        '$updateUserUrl/$userId',
        headers: headers,
        body: body,
      );

      log('Update user details response: ${response.body}');
    } catch (e) {
      throw Exception('Error updating user details: $e');
    }
  }
}
