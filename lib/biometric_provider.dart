import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fx_helper/secure_storage.dart';
import 'package:fx_helper/snackbar_helper.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/types/auth_messages_ios.dart';

/// A helper class to handle **biometric authentication** (fingerprint, face ID) across Android and iOS.
///
/// This class provides utilities to check device support, available biometric types,
/// and perform user authentication using biometrics.
class BiometricProvider extends ChangeNotifier {
  bool isLoading = true;
  bool _isBioSupported = false;
  bool allowLoginWithBiometric = false;
  bool isBioEnabled = false;
  late final LocalAuthentication auth;

  BiometricProvider() {
    try {
      isLoading = true;
      auth = LocalAuthentication();
      _checkBiometric();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> isEnabled() async {
    try {
      isBioEnabled = await SecureStorage().getAllowBiometricLogin();
    } catch (e) {
      print(e.toString());
    }
    return isBioEnabled;
  }

  Future<bool> _isSupported() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      print("canAuthenticateWithBiometrics: $canAuthenticateWithBiometrics");
      _isBioSupported = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    } catch (e) {
      print(e.toString());
    }
    return _isBioSupported;
  }

  Future<void> _checkBiometric() async {
    try {
      isBioEnabled = await isEnabled();
      _isBioSupported = await _isSupported();
      _checkAllowLoginWithBiometric();

      print("===");
      print("isBiometricSupported : $_isBioSupported");
      print("isBiometricEnabled : $isBioEnabled");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> changeBiometric({bool? isEnabled}) async {
    print("changeBiometric()");
    isLoading = true;
    notifyListeners();
    try {
      await _checkBiometric();
      if (isEnabled ?? !isBioEnabled) {
        bool isSuccess = await authenticate();
        if (isSuccess) {
          var currentSetting = await this.isEnabled();
          await SecureStorage().setAllowBiometricLogin(isEnabled ?? !currentSetting);
        } else {
          SnackbarHelper.showSnackBar(SnackbarState.warning, "Authentikasi Gagal");
        }
      } else {
        var currentSetting = await this.isEnabled();
        await SecureStorage().setAllowBiometricLogin(isEnabled ?? !currentSetting);
      }
      await _checkBiometric();
    } catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
    print("changeBiometric() done");
  }

  Future<bool> _checkAllowLoginWithBiometric() async {
    try {
      // String email = await SecureStorage().getBiometricEmail();
      // String password = await SecureStorage().getBiometricPassword();
      // bool isEmailPassCorrect =
      //     ValidatorHelper.validateEmail(email) == null && ValidatorHelper.validatePassword(password) == null;
      allowLoginWithBiometric = await _isSupported() && await isEnabled();
    } catch (e) {
      print(e.toString());
    }

    return allowLoginWithBiometric;
  }

  Future<bool> setBiometricLoginData({String? currentLoginEmail, String? currentLoginPassword}) async {
    try {
      String oldEmail = await SecureStorage().getBiometricEmail();
      String oldPassword = await SecureStorage().getBiometricPassword();

      if (await isEnabled() &&
          (oldEmail.isEmpty ||
              oldPassword.isEmpty ||
              currentLoginEmail == null ||
              currentLoginEmail.isEmpty ||
              currentLoginPassword == null ||
              currentLoginPassword.isEmpty ||
              oldEmail != currentLoginEmail ||
              oldPassword != currentLoginPassword)) {
        await SecureStorage().setAllowBiometricLogin(false);
        await _checkAllowLoginWithBiometric();
        SnackbarHelper.showSnackBar(
          SnackbarState.success,
          "To protect your privacy, we have cleared previous biometric login. You can reactivate this feature from settings",
          duration: Duration(seconds: 10),
        );
      }
      await SecureStorage().setBiometricEmail(currentLoginEmail ?? "");
      await SecureStorage().setBiometricPassword(currentLoginPassword ?? "");
    } catch (e) {
      print(e.toString());
    }

    return allowLoginWithBiometric;
  }

  // Future<List<BiometricType>> getAvailableBiometrics() async {
  //   return await auth.getAvailableBiometrics();
  // }

  Future<bool> authenticate({
    String title = "Authentication is Required",
    String message = "Authentication is Required to access this feature",
    String cancelTitle = "Cancel",
  }) async {
    bool didAuthenticate = false;
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
      print('platform exception: ${e.toString()}');
    } catch (e) {
      print(e.toString());
    }
    return didAuthenticate;
  }
}
