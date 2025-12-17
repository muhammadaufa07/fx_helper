import 'dart:developer';

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
      refresh().then((value) {
        isLoading = false;
        notifyListeners();
      });
      isLoading = false;
      notifyListeners();
    } catch (e) {
      log("BiometricProvider(): $e");
    }
  }
  Future<void> refresh() async {
    isLoading = true;
    try {
      isBioEnabled = await SecureStorage().getAllowBiometricLogin();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      _isBioSupported = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      allowLoginWithBiometric = _isBioSupported && isBioEnabled;
      // log("isBioEnabled: $isBioEnabled");
      // log("canAuthenticateWithBiometrics: $canAuthenticateWithBiometrics");
      // log("_isBioSupported: $_isBioSupported");
      // log("allowLoginWithBiometric: $allowLoginWithBiometric");
    } catch (e) {
      log("BiometricProvider: refresh() $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> changeBiometric({bool? enabled}) async {
    log("changeBiometric()");
    isLoading = true;
    notifyListeners();
    try {
      await refresh();
      if (enabled ?? !isBioEnabled) {
        bool isSuccess = await authenticate();
        if (isSuccess) {
          await SecureStorage().setAllowBiometricLogin(enabled ?? !isBioEnabled);
        } else {
          SnackbarHelper.showSnackBar(SnackbarState.warning, "Authentikasi Gagal");
        }
      } else {
        await SecureStorage().setAllowBiometricLogin(enabled ?? !isBioEnabled);
      }
      // await _checkBiometric();
    } catch (e) {
      log("changeBiometric(): $e");
    }
    await refresh();
    isLoading = false;
    notifyListeners();
    log("changeBiometric() done");
  }

  Future<void> setBiometricLoginData({String? currentLoginEmail, String? currentLoginPassword}) async {
    log("currentLoginEmail $currentLoginEmail");
    log("currentLoginPassword $currentLoginPassword");
    try {
      String oldEmail = await SecureStorage().getBiometricEmail();
      String oldPassword = await SecureStorage().getBiometricPassword();

      if (isBioEnabled &&
          (oldEmail.isEmpty ||
              oldPassword.isEmpty ||
              currentLoginEmail == null ||
              currentLoginEmail.isEmpty ||
              currentLoginPassword == null ||
              currentLoginPassword.isEmpty ||
              oldEmail != currentLoginEmail ||
              oldPassword != currentLoginPassword)) {
        await SecureStorage().setAllowBiometricLogin(false);
        SnackbarHelper.showSnackBar(
          SnackbarState.success,
          "To protect your privacy, we have cleared previous biometric login. You can reactivate this feature from settings",
          duration: Duration(seconds: 10),
        );
      }
      await SecureStorage().setBiometricEmail(currentLoginEmail ?? "");
      await SecureStorage().setBiometricPassword(currentLoginPassword ?? "");
    } catch (e) {
      log("setBiometricLoginData(): $e");
    }
    await refresh();
    notifyListeners();
  }

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
        sensitiveTransaction: true,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      log("authenticate(): $e");
    } catch (e) {
      log("authenticate2(): $e");
    }
    return didAuthenticate;
  }
}
