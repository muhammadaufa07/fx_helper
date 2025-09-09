class RegexpHelper {
  static bool isEmail(String email) {
    // String regex =
    // r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";
    String regex = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(email);
  }

  static bool isPhoneNumber(String phoneNumber) {
    String regex = r'^8[\d]{8,15}$';
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(phoneNumber);
  }

  static bool isNPWP(String npwp) {
    String regex = r'^\d{2}\.\d{3}\.\d{3}\.\d{1}-\d{3}\.\d{3}$';
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(npwp);
  }

  static bool isPassword(String password) {
    RegExp hasUppercase = RegExp(r'(?=.*[A-Z])');
    RegExp hasLowercase = RegExp(r'(?=.*[a-z])');
    RegExp hasDigit = RegExp(r'(?=.*[0-9])');
    RegExp hasSpecialChar = RegExp(r'(?=.*[!@#$&])');
    RegExp hasMinLength = RegExp(r'.{8,}');

    return hasUppercase.hasMatch(password) &&
        hasLowercase.hasMatch(password) &&
        hasDigit.hasMatch(password) &&
        hasSpecialChar.hasMatch(password) &&
        hasMinLength.hasMatch(password);
  }

  static String getPasswordWarning(String password) {
    String warning = '';

    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      warning += '- 1 huruf besar.\n';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      warning += '- 1 huruf kecil.\n';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(password)) {
      warning += '- 1 angka.\n';
    }
    if (!RegExp(r'(?=.*[!@#\$&])').hasMatch(password)) {
      warning += '- 1 special character (!@#\$&).\n';
    }
    if (password.length < 8) {
      warning += '- 8 karakter.\n';
    }

    return warning.isNotEmpty ? warning : '';
  }
}
