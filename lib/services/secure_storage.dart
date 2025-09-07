import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'breaker_token';
  static const _usernameKey = 'breaker_username';

  // Token
  static Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  static Future<void> setToken(String token) async => await _storage.write(key: _tokenKey, value: token);
  static Future<void> clearToken() async => await _storage.delete(key: _tokenKey);

  // Username
  static Future<String?> getUsername() async => await _storage.read(key: _usernameKey);
  static Future<void> setUsername(String username) async => await _storage.write(key: _usernameKey, value: username);
  static Future<void> clearUsername() async => await _storage.delete(key: _usernameKey);


}
