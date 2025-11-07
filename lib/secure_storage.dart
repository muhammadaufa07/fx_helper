import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Gunakan singleton agar tidak membuat banyak instance
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Gunakan EncryptedSharedPreferences di Android
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device, // iOS: hanya setelah pertama unlock
    ),
  );

  static const bool simulateSecureStorageError = false;

  /// --- Utility: Safe Read ---
  Future<String?> safeRead(String key) async {
    try {
      if (simulateSecureStorageError && key == "token") {
        throw Exception("javax.crypto.AEADBadTagException: fake debug error");
      }

      return await storage.read(key: key);
    } catch (e, st) {
      final msg = e.toString();
      log("⚠️ SecureStorage read error [$key]: $msg", stackTrace: st);

      // Tangani error umum Android & iOS
      if (msg.contains("AEADBadTagException") ||
          msg.contains("KeyPermanentlyInvalidatedException") ||
          msg.contains("UnrecoverableKeyException") ||
          msg.contains("errSecDecode")) {
        log("🧹 SecureStorage: corrupted key [$key], deleting...");
        await storage.delete(key: key);
        return null;
      }

      // Tangani edge case lain (misal NullPointerException)
      if (msg.contains("NullPointerException")) {
        log("🧩 SecureStorage: null pointer issue [$key], reset key...");
        await storage.delete(key: key);
        return null;
      }

      rethrow;
    }
  }

  /// --- Safe Write (tambahan untuk stabilitas) ---
  Future<void> _safeWrite(String key, String value) async {
    try {
      await storage.write(key: key, value: value);
    } catch (e, st) {
      log("❌ SecureStorage write error [$key]: $e", stackTrace: st);
      if (e.toString().contains("AEADBadTagException")) {
        await storage.delete(key: key);
        await storage.write(key: key, value: value);
      } else {
        rethrow;
      }
    }
  }

  /// --- Token ---
  Future<void> setToken(String value) async => await _safeWrite("token", value);

  Future<String?> getToken() async => await safeRead("token");

  Future<void> deleteToken() async => await storage.delete(key: "token");

  /// --- Biometric ---
  Future<void> setAllowBiometricLogin(bool value) async => await _safeWrite("allowBiometricLogin", value.toString());

  Future<bool> getAllowBiometricLogin() async => (await safeRead("allowBiometricLogin")) == "true";

  Future<void> setBiometricEmail(String value) async => await _safeWrite("biometric_email", value);

  Future<String> getBiometricEmail() async => await safeRead("biometric_email") ?? "";

  Future<void> setBiometricPassword(String value) async => await _safeWrite("biometric_password", value);

  Future<String> getBiometricPassword() async => await safeRead("biometric_password") ?? "";

  /// --- OnBoarding ---
  Future<void> setOnBoarding(bool value) async => await _safeWrite("onBoarding", value.toString());

  Future<bool> getOnBoarding() async => (await safeRead("onBoarding"))?.toLowerCase() == "true";

  /// --- Global Delete ---
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  Future<void> deleteAllLoginData() async {
    await storage.delete(key: "token");
    await storage.delete(key: "biometric_email");
    await storage.delete(key: "biometric_password");
  }
}
