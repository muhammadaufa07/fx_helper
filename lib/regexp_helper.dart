class RegexpHelper {
  /// Validates if a string is a valid email address.
  ///
  /// Example:
  /// ```dart
  /// RegexpHelper.isEmail("test@example.com"); // true
  /// RegexpHelper.isEmail("invalid_email"); // false
  /// ```
  static bool isEmail(String? email) {
    String regex = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(email ?? "");
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
  static bool isPhoneNumber(String? phoneNumber) {
    String regex = r'^8[\d]{8,15}$';
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(phoneNumber ?? "");
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
  static bool isNPWP(String? npwp) {
    String regex = r'^\d{2}\.\d{3}\.\d{3}\.\d{1}-\d{3}\.\d{3}$';
    RegExp regExp = RegExp(regex);
    return regExp.hasMatch(npwp ?? "");
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
  static bool isPassword(String? password) {
    return hasUpper(password) &&
        hasLower(password) &&
        hasNumber(password) &&
        hasSpecialChar(password) &&
        (password ?? "").length >= 8;
  }

  static bool hasUpper(String? text) {
    return RegExp(r'(?=.*[A-Z])').hasMatch(text ?? "");
  }

  static bool hasLower(String? text) {
    return RegExp(r'(?=.*[a-z])').hasMatch(text ?? "");
  }

  static bool hasNumber(String? text) {
    return RegExp(r'(?=.*[0-9])').hasMatch(text ?? "");
  }

  static bool hasSpecialChar(String? text) {
    return RegExp(r'(?=.*[!@#\$&])').hasMatch(text ?? "");
  }

  /// find youtube video id from youtube url
  ///
  /// example:
  ///     https://www.youtube.com/watch?v=Am5vjvyPjls
  ///   returns : "Am5vjvyPjls"
  ///
  static String? matchAndGetYoutubeVideoId(String? text) {
    return RegExp(r'(?<=v\=)[a-zA-Z0-9][a-zA-Z0-9]*(?<!\&)').allMatches(text ?? "").first[0];
  }

  static bool isUrl(String? text) {
    /* Not regexp but handy to handle url checking */
    return Uri.tryParse(text ?? "")?.hasAbsolutePath ?? false;
  }
}
