import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  // Singleton pattern
  SecureStorageHelper._privateConstructor();
  static final SecureStorageHelper instance = SecureStorageHelper._privateConstructor();

  // FlutterSecureStorage instance with proper configuration
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys
  static const String _keyAccessToken = 'ACCESS_TOKEN';
  static const String _keyRefreshToken = 'REFRESH_TOKEN';
  static const String _keyUsername = 'USERNAME';
  static const String _keyPassword = 'PASSWORD';
  static const String _keyBiometricEnabled = 'BIOMETRIC_ENABLED';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _keyAccessToken, value: token);
    } catch (e) {
      debugPrint('Error saving access token: $e');
      rethrow;
    }
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
    } catch (e) {
      debugPrint('Error saving refresh token: $e');
      rethrow;
    }
  }

  /// Read access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (e) {
      debugPrint('Error reading access token: $e');
      return null;
    }
  }

  /// Read refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('Error reading refresh token: $e');
      return null;
    }
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: _keyAccessToken);
    } catch (e) {
      debugPrint('Error deleting access token: $e');
    }
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('Error deleting refresh token: $e');
    }
  }

  // Biometric Login Support
  
  /// Save credentials for biometric login
  Future<void> saveCredentials(String username, String password) async {
    try {
      await _storage.write(key: _keyUsername, value: username);
      await _storage.write(key: _keyPassword, value: password);
    } catch (e) {
      debugPrint('Error saving credentials: $e');
      rethrow;
    }
  }

  /// Get saved username
  Future<String?> getUsername() async {
    try {
      return await _storage.read(key: _keyUsername);
    } catch (e) {
      debugPrint('Error reading username: $e');
      return null;
    }
  }

  /// Get saved password
  Future<String?> getPassword() async {
    try {
      return await _storage.read(key: _keyPassword);
    } catch (e) {
      debugPrint('Error reading password: $e');
      return null;
    }
  }

  /// Enable biometric login
  Future<void> enableBiometric() async {
    try {
      await _storage.write(key: _keyBiometricEnabled, value: 'true');
    } catch (e) {
      debugPrint('Error enabling biometric: $e');
    }
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    try {
      await _storage.delete(key: _keyBiometricEnabled);
      await _storage.delete(key: _keyUsername);
      await _storage.delete(key: _keyPassword);
    } catch (e) {
      debugPrint('Error disabling biometric: $e');
    }
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _keyBiometricEnabled);
      return value == 'true';
    } catch (e) {
      debugPrint('Error checking biometric status: $e');
      return false;
    }
  }

  /// Save data (generic)
  Future<void> saveData({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error saving data for key $key: $e');
      rethrow;
    }
  }

  /// Delete data (generic)
  Future<void> deleteData({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('Error deleting data for key $key: $e');
    }
  }

  /// Get data (generic)
  Future<String?> getData({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('Error reading data for key $key: $e');
      return null;
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      debugPrint('Error checking key $key: $e');
      return false;
    }
  }

  /// Get all keys
  Future<Map<String, String>> getAllData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('Error reading all data: $e');
      return {};
    }
  }

  /// Delete all tokens (logout)
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      // Note: Don't delete credentials for biometric login
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
    }
  }

  /// Delete all data (complete logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }
}
