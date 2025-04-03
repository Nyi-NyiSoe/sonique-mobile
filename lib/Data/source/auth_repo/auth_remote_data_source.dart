import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sonique/Data/models/user_model.dart';

class AuthRemoteDataSource {
  final http.Client client;
  late String loginUrl;
  late String registerUrl;
  AuthRemoteDataSource({required this.client}) {
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
      response = await client.post(
        Uri.parse(loginUrl),
        headers: headers,
        body: body,
      );
      log(response.body);
    } catch (e) {
      throw Exception(' error: $e');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Login response: ${data['data']}');
      
      return UserModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
}
