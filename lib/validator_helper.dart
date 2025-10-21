import 'package:fx_helper/regexp_helper.dart';

class ValidatorHelper {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Silakan masukkan email anda";
    } else if (!RegexpHelper.isEmail(email)) {
      return "Format email salah";
    }
    return null;
  }

  static String? _passwordWarning(String? p) {
    String warning = '';
    if (!RegexpHelper.hasUpper(p)) {
      warning += '    • 1 Huruf Kapital.\n';
    }
    if (!RegexpHelper.hasLower(p)) {
      warning += '    • 1 Huruf Kecil.\n';
    }
    if (!RegexpHelper.hasNumber(p)) {
      warning += '    • 1 Angka.\n';
    }
    if (!RegexpHelper.hasSpecialChar(p)) {
      warning += '    • 1 Special Character (!@#\$&).\n';
    }
    if ((p ?? "").length < 8) {
      warning += '    • 8 karakter.\n';
    }

    return warning;
  }

  static String? validatePassword(String? password, {String? password2}) {
    print("validatePassword($password, $password2)");
    if (password == null || password.isEmpty) {
      return "Silahkan Masukkan Password Anda";
    } else if (!RegexpHelper.isPassword(password)) {
      return "Password setidak nya memiliki:\n${_passwordWarning(password ?? "")}";
    } else if (password2 != null && password != password2) {
      return "Password tidak sama";
    }
    return null;
  }

  static String? validateText(String? text) {
    if (text == null || text.isEmpty) {
      return "Field kosong";
    }

    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return "Silakan masukkan nomor telepon anda";
    } else if (!RegexpHelper.isPhoneNumber(phone)) {
      return "Format nomor telepon salah (852 xxxx xxxx )";
    }
    return null;
  }

  static String? validateNPWP(String? npwp) {
    if (npwp == null || npwp.isEmpty) {
      return "Silakan masukkan NPWP anda";
    } else if (!RegexpHelper.isNPWP(npwp)) {
      return "Format NPWP salah\n format: XX.XXX.XXX.X-XXX.XXX";
    }
    return null;
  }
}
