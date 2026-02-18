import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";
  static const _usernameKey = "username";

  static Future<void> saveLogin(String username, String token) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
