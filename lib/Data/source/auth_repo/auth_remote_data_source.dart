import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sonique/Data/core/api_client.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_token_storage.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;
  late String loginUrl;
  late String registerUrl;
  final AuthTokenStorage tokenStorage;
  AuthRemoteDataSource({required this.apiClient, required this.tokenStorage}) {
    loginUrl = dotenv.env['LOGIN_URL'] ?? '';
    registerUrl = dotenv.env['REGISTER_URL'] ?? '';

    if (loginUrl.isEmpty || registerUrl.isEmpty) {
      throw Exception('API URLs are not set in .env file');
    }
  }

  Future<UserModel> login(String email, String password) async {
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    late final http.Response response;
    try {
      response = await apiClient.post(loginUrl, headers: headers, body: body);

      log(response.body);
    } catch (e) {
      throw Exception(' error: $e');
    }

    if (response.statusCode == 200) {
      String? token;
      String? refreshToken;
      String? cookies;
      if (response.headers.containsKey('set-cookie')) {
        cookies = response.headers['set-cookie']!;
      }

      if (cookies!.contains('token=')) {
        token = _extractCookieValue(cookies, 'token');
      }

      if (cookies.contains('refreshToken=')) {
        refreshToken = _extractCookieValue(cookies, 'refreshToken');
      }

      log('Token: $token');
      log('Refresh Token: $refreshToken');
      await tokenStorage.saveTokens(token!, refreshToken!);

      final data = jsonDecode(response.body);
      log('Login response: ${data['data']}');

      return UserModel.fromJson(
        data['data'],
        token: token,
        refreshToken: refreshToken,
      );
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<UserModel> register(
    String email,
    String firstName,
    String lastName,
    String password,
    String username,
  ) async {
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'username': username,
    });

    late final http.Response response;
    try {
      response = await apiClient.post(
        registerUrl,
        headers: headers,
        body: body,
      );
      log("Register response: ${response.body}");
    } catch (e) {
      throw Exception(' error: $e');
    }

    log(response.statusCode.toString());
    if (response.statusCode == 201) {
      String? token;
      String? refreshToken;
      String? cookies;
      if (response.headers.containsKey('set-cookie')) {
        cookies = response.headers['set-cookie']!;
      }

      if (cookies!.contains('token=')) {
        token = _extractCookieValue(cookies, 'token');
      }

      if (cookies.contains('refreshToken=')) {
        refreshToken = _extractCookieValue(cookies, 'refreshToken');
      }

      log('Token: $token');
      log('Refresh Token: $refreshToken');
      await tokenStorage.saveTokens(token!, refreshToken!);
      final data = jsonDecode(response.body);
      log('FULL JSON: $data'); // 👈 Add this
      log('user change: ${data['data']}');

      return UserModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
}

String? _extractCookieValue(String cookies, String key) {
  final regex = RegExp('$key=([^;]*)');
  final match = regex.firstMatch(cookies);
  return match?.group(1);
}
