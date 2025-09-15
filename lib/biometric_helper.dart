import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/types/auth_messages_ios.dart';

// enum BiometricResult  {
//   f
// }
class BiometricHelper {
  late final LocalAuthentication auth;
  BiometricHelper() {
    auth = LocalAuthentication();
  }

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    print("canAuthenticateWithBiometrics");
    print(canAuthenticateWithBiometrics);
    print(await auth.isDeviceSupported());
    return canAuthenticate;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await auth.getAvailableBiometrics();
  }

  Future<void> authenticate({
    String title = "Authentication is Required",
    String message = "Authentication is Required to access this feature",
    String cancelTitle = "Cancel",
    required Function(bool isSuccess, String info) callback,
  }) async {
    bool didAuthenticate = false;
    String info = "";
    try {
      // if (await isBiometricAvailable()) {
      //   if ((await getAvailableBiometrics()).isNotEmpty) {
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
      //   } else {
      //     info = "Biometric Not Found";
      //   }
      // } else {
      //   info = "Biometric is not Available";
      // }
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

  Future<bool> validate(Function(bool status) callback) async {
    /*  */

    // if (await _isBiometricAvailable()) {
    //   await authenticate(callback);
    // } else {
    //   print("Biometric is not available on this device");
    // }

    // if (availableBiometrics.isNotEmpty) {
    //   print("availableBiometrics");
    //   print(availableBiometrics);
    // }

    // if (availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.face)) {
    //   // Specific types of biometrics are available.
    //   // Use checks like this with caution!
    // }
    /*  */

    // print("canAuthenticate: ${canAuthenticate}");

    try {
      // }

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("isUnlock: $didAuthenticate")));
    } on PlatformException {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong")));
      print("Something went wrong");
    } catch (e) {
      print("Generic Exception");
      print(e);
    }
    return false;
  }
}
