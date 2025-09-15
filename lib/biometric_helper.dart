import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/types/auth_messages_ios.dart';

class BiometricHelper {
  late final LocalAuthentication auth;
  BiometricHelper() {
    auth = LocalAuthentication();
  }

  /// Check if biometric is available
  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    print("canAuthenticateWithBiometrics");
    print(canAuthenticateWithBiometrics);
    print(await auth.isDeviceSupported());
    return canAuthenticate;
  }

  /// get data is biometric allowed
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await auth.getAvailableBiometrics();
  }

  /// Authenticate user with biometric
  Future<void> authenticate({
    String title = "Authentication is Required",
    String message = "Authentication is Required to access this feature",
    String cancelTitle = "Cancel",
    required Function(bool isSuccess, String info) callback,
  }) async {
    bool didAuthenticate = false;
    String info = "";
    try {
      didAuthenticate = await auth.authenticate(
        localizedReason: message,
        authMessages: <AuthMessages>[
          AndroidAuthMessages(signInTitle: title, cancelButton: cancelTitle),
          IOSAuthMessages(cancelButton: cancelTitle),
        ],
        options: AuthenticationOptions(
          sensitiveTransaction: true,
          useErrorDialogs: true,
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      info = "Biometric Error";
      print('platform exception: $e');
      print("platform Exception");
    } catch (e) {
      info = "Biometric Error gen";
      print(e);
    }
    callback(didAuthenticate, info);
  }
}
