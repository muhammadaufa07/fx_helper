import 'package:encrypt/encrypt.dart';

/* Standard Encryption Helper */
class EncryptHelper {
  static String aesEncrypt(
    String key,
    String data, {
    /*  */
    String? ivStr,
    AESMode mode = AESMode.cbc,
  }) {
    String chiper = "";
    try {
      final IV iv = IV.fromUtf8(ivStr ?? "");
      final Key utf8Key = Key.fromUtf8(key);
      final alg = AES(utf8Key, mode: mode);
      Encrypter encrypter = Encrypter(alg);
      final encrypted = encrypter.encrypt(data, iv: iv);
      chiper = encrypted.base64;
    } catch (e) {
      print(e.toString());
    }
    return chiper;
  }

  String aesDecrypt(
    String key,
    String chiper, {
    /*  */
    String? ivStr,
    AESMode? mode = AESMode.cbc,
  }) {
    String d = "";
    try {
      final IV iv = IV.fromUtf8(ivStr ?? "");
      final Key utf8Key = Key.fromUtf8(key);
      final alg = AES(utf8Key, mode: AESMode.ctr);
      Encrypter encrypter = Encrypter(alg);
      final encrypted = Encrypted.from64(chiper);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      d = decrypted;
    } catch (e) {
      print(e.toString());
    }

    return d;
  }
}
