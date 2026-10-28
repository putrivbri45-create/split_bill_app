import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._();
  static SecurityService get instance => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  SecurityService._();

  static const String _tokenKey = 'patungan_jwt_token';
  static const String _userSessionKey = 'patungan_user_session';
  static const String _biometricEnabledKey = 'patungan_biometric_enabled';

  static const int _pbkdf2Iterations = 12000;
  static const String _legacySalt = 'patungan_salt_2026';

  /// Hashes a password with PBKDF2-HMAC-SHA256 and a random per-user salt.
  /// Output format: `pbkdf2$<iterations>$<saltB64>$<hashB64>`.
  String hashPassword(String password, {String? salt, int iterations = _pbkdf2Iterations}) {
    final saltBytes = salt != null ? base64Decode(salt) : _randomBytes(16);
    final derived = _pbkdf2(utf8.encode(password), saltBytes, iterations, 32);
    return 'pbkdf2\$$iterations\$${base64Encode(saltBytes)}\$${base64Encode(derived)}';
  }

  /// Verifies a password against a stored hash (PBKDF2 or legacy SHA-256).
  bool verifyPassword(String password, String storedHash) {
    final parts = storedHash.split(r'$');
    if (parts.length == 4 && parts[0] == 'pbkdf2') {
      final iterations = int.tryParse(parts[1]) ?? _pbkdf2Iterations;
      final candidate = hashPassword(password, salt: parts[2], iterations: iterations);
      return _constantTimeEquals(candidate, storedHash);
    }
    // Legacy: SHA-256 with static salt (accounts created before v1.0.0)
    final legacy = sha256.convert(utf8.encode('$password:$_legacySalt')).toString();
    return _constantTimeEquals(legacy, storedHash);
  }

  List<int> _randomBytes(int length) {
    final rnd = Random.secure();
    return List<int>.generate(length, (_) => rnd.nextInt(256));
  }

  List<int> _pbkdf2(List<int> password, List<int> salt, int iterations, int keyLength) {
    final hmac = Hmac(sha256, password);
    final blocks = (keyLength / 32).ceil();
    final out = <int>[];
    for (var i = 1; i <= blocks; i++) {
      final blockIndex = [(i >> 24) & 0xff, (i >> 16) & 0xff, (i >> 8) & 0xff, i & 0xff];
      var u = hmac.convert([...salt, ...blockIndex]).bytes;
      final t = List<int>.from(u);
      for (var j = 1; j < iterations; j++) {
        u = hmac.convert(u).bytes;
        for (var k = 0; k < t.length; k++) {
          t[k] ^= u[k];
        }
      }
      out.addAll(t);
    }
    return out.sublist(0, keyLength);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// Saves session token securely
  Future<void> saveSessionToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Retrieves stored session token
  Future<String?> getSessionToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Saves user session details
  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    await _secureStorage.write(key: _userSessionKey, value: jsonEncode(userData));
  }

  /// Retrieves stored user session
  Future<Map<String, dynamic>?> getUserSession() async {
    final data = await _secureStorage.read(key: _userSessionKey);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Clears secure session (Logout)
  Future<void> clearSession() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userSessionKey);
  }

  /// Biometric Authentication Trigger
  Future<bool> authenticateBiometrics({String localizedReason = 'Verifikasi identitas Anda untuk melanjutkan'}) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck && !isDeviceSupported) {
        return true; // Gracefully pass on devices without biometric hardware
      }
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == 'true';
  }
}
