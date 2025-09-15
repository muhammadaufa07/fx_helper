class RegexpHelper {
  /// Validates if a string is a valid email address.
  ///
  /// Example:
  /// ```dart
  /// RegexpHelper.isEmail("test@example.com"); // true
  /// RegexpHelper.isEmail("invalid_email"); // false
  /// ```
  static bool isEmail(String email) {
    String regex = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(email);
  }

  /// Validates if a string is a valid Indonesian phone number format.
  ///
  /// The format must:
  /// - Start with `8`
  /// - Contain 9–16 digits total (including the first `8`)
  ///
  /// Example:
  /// ```dart
  /// RegexpHelper.isPhoneNumber("8123456789"); // true
  /// RegexpHelper.isPhoneNumber("712345678");  // false
  /// ```
  static bool isPhoneNumber(String phoneNumber) {
    String regex = r'^8[\d]{8,15}$';
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(phoneNumber);
  }

  /// Validates if a string is a valid NPWP (Indonesian Tax ID).
  ///
  /// The format must be: `99.999.999.9-999.999`
  ///
  /// Example:
  /// ```dart
  /// RegexpHelper.isNPWP("12.345.678.9-012.345"); // true
  /// RegexpHelper.isNPWP("123456789012345");      // false
  /// ```
  static bool isNPWP(String npwp) {
    String regex = r'^\d{2}\.\d{3}\.\d{3}\.\d{1}-\d{3}\.\d{3}$';
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(npwp);
  }

  /// Validates if a password meets the following rules:
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 digit
  /// - At least 1 special character (`!@#$&`)
  /// - Minimum length of 8 characters
  ///
  /// Example:
  /// ```dart
  /// RegexpHelper.isPassword("Password1!"); // true
  /// RegexpHelper.isPassword("password");   // false
  /// ```
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

  /// Returns a warning message for a password if it does not meet the requirements.
  ///
  /// The warning message is in **Indonesian**, listing what is missing:
  /// - `1 huruf besar.` → missing uppercase letter
  /// - `1 huruf kecil.` → missing lowercase letter
  /// - `1 angka.` → missing digit
  /// - `1 special character (!@#$&).` → missing special character
  /// - `8 karakter.` → password too short
  ///
  /// Example:
  /// ```dart
  /// RegexpHelper.getPasswordWarning("pass");
  /// // "- 1 huruf besar.\n- 1 angka.\n- 1 special character (!@#$&).\n- 8 karakter.\n"
  ///
  /// RegexpHelper.getPasswordWarning("Password1!");
  /// // ""
  /// ```
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
