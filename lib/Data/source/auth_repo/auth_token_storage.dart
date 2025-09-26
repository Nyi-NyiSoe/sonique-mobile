import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  final FlutterSecureStorage _secureStorage;

  AuthTokenStorage(this._secureStorage);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessKey, value: accessToken);
    await _secureStorage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _secureStorage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _secureStorage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessKey);
    await _secureStorage.delete(key: _refreshKey);
  }
}
