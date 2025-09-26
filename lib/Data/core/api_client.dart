import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:sonique/Data/source/auth_repo/auth_token_storage.dart';

/// A simple wrapper around http.Client for handling JWT + headers
class ApiClient {
  final http.Client _client;
  final AuthTokenStorage _tokenStorage;

  ApiClient({
    required http.Client client,
    required AuthTokenStorage tokenStorage,
  }) : _client = client,
       _tokenStorage = tokenStorage;

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    log("ApiClient get req token: $token");
    return _client.get(
      Uri.parse('$endpoint'),
      headers: _withCookieHeader(token, refreshToken, headers),
    );
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    return _client.post(
      Uri.parse('$endpoint'),
      headers: _withCookieHeader(token, refreshToken, headers),
      body: body,
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    return _client.patch(
      Uri.parse('$endpoint'),
      headers: _withCookieHeader(token, refreshToken, headers),
      body: body,
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    return _client.put(
      Uri.parse('$endpoint'),
      headers: _withCookieHeader(token, refreshToken, headers),
      body: body,
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    return _client.delete(
      Uri.parse('$endpoint'),
      headers: _withCookieHeader(token, refreshToken, headers),
      body: body,
    );
  }

  Future<http.StreamedResponse> sendMultipart({
    required String endpoint,
    Map<String, String>? files, // multiple files, key = field name
    Map<String, String>? fields, // additional form fields
    Map<String, String>? headers, // extra headers
    String method = 'POST', // HTTP method
    bool includeCookies = true, // attach token cookies
  }) async {
    // Get tokens
    final token = includeCookies ? await _tokenStorage.getAccessToken() : null;
    final refreshToken =
        includeCookies ? await _tokenStorage.getRefreshToken() : null;

    final uri = Uri.parse(endpoint);
    final request = http.MultipartRequest(method, uri);

    // Add JWT cookies if required
    if (includeCookies) {
      request.headers.addAll(_withCookieHeader(token, refreshToken, headers));
    } else if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add files
    if (files != null) {
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }
    }

    // Add form fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Send request
    return request.send();
  }

  /// Helper for merging headers + adding Authorization
  Map<String, String> _withCookieHeader(
    String? accessToken,
    String? refreshToken,
    Map<String, String>? headers,
  ) {
    final cookieHeader =
        (accessToken != null && refreshToken != null)
            ? {'Cookie': 'token=$accessToken;refreshToken=$refreshToken'}
            : {};
    return {'Content-Type': 'application/json', ...?headers, ...cookieHeader};
  }
}
