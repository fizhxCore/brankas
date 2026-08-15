import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const _idKey = 'brankas_id';
  static const _passKey = 'brankas_password';
  static const _sessionKey = 'brankas_session';

  Future<bool> hasAccount() async {
    final id = await _storage.read(key: _idKey);
    return id != null && id.isNotEmpty;
  }

  Future<void> createAccount(String id, String password) async {
    await _storage.write(key: _idKey, value: id);
    await _storage.write(key: _passKey, value: password);
  }

  Future<bool> login(String id, String password) async {
    final savedId = await _storage.read(key: _idKey);
    final savedPass = await _storage.read(key: _passKey);
    final ok = savedId == id && savedPass == password;
    if (ok) {
      await _storage.write(key: _sessionKey, value: 'active');
    }
    return ok;
  }

  Future<bool> isLoggedIn() async {
    final s = await _storage.read(key: _sessionKey);
    return s == 'active';
  }

  Future<void> logout() async {
    await _storage.delete(key: _sessionKey);
  }

  Future<void> changePassword(String newPassword) async {
    await _storage.write(key: _passKey, value: newPassword);
  }
}
