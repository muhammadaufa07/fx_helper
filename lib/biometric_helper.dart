import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/types/auth_messages_ios.dart';

/// A helper class to handle **biometric authentication** (fingerprint, face ID) across Android and iOS.
///
/// This class provides utilities to check device support, available biometric types,
/// and perform user authentication using biometrics.
class BiometricHelper {
  late final LocalAuthentication auth;

  /// Constructor initializes the [LocalAuthentication] instance.
  BiometricHelper() {
    auth = LocalAuthentication();
  }

  /// Checks if **biometric authentication** is available and supported on the device.
  ///
  /// Returns `true` if the device can perform biometric authentication, otherwise `false`.
  ///
  /// ### Example:
  /// ```dart
  /// final biometricHelper = BiometricHelper();
  /// final available = await biometricHelper.isBiometricAvailable();
  /// print('Biometric available: $available');
  /// ```
  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    print("canAuthenticateWithBiometrics");
    print(canAuthenticateWithBiometrics);
    print(await auth.isDeviceSupported());
    return canAuthenticate;
  }

  /// Gets a list of **available biometric types** supported by the device.
  ///
  /// Returns a [List<BiometricType>] such as `BiometricType.fingerprint` or `BiometricType.face`.
  ///
  /// ### Example:
  /// ```dart
  /// final biometricHelper = BiometricHelper();
  /// final biometrics = await biometricHelper.getAvailableBiometrics();
  /// print('Available biometrics: $biometrics');
  /// ```
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await auth.getAvailableBiometrics();
  }

  /// Prompts the user to **authenticate using biometrics**.
  ///
  /// Parameters:
  /// - [title]: Title displayed on Android authentication dialog (default: `"Authentication is Required"`).
  /// - [message]: Reason displayed to the user for authentication (default: `"Authentication is Required to access this feature"`).
  /// - [cancelTitle]: Text for the cancel button on Android/iOS (default: `"Cancel"`).
  /// - [callback]: Function called after authentication completes, returns:
  ///   - `isSuccess` → `true` if authentication succeeded, `false` otherwise.
  ///   - `info` → A string message describing error or status.
  ///
  /// ### Example:
  /// ```dart
  /// final biometricHelper = BiometricHelper();
  /// await biometricHelper.authenticate(
  ///   title: 'Unlock App',
  ///   message: 'Please authenticate to continue',
  ///   callback: (isSuccess, info) {
  ///     if (isSuccess) {
  ///       print('Authentication successful');
  ///     } else {
  ///       print('Authentication failed: $info');
  ///     }
  ///   },
  /// );
  /// ```
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
