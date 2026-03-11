import 'package:encrypt/encrypt.dart';
import 'package:password_saver/repository/appSettings.dart';
class CryptoHelper  {
  static final key = Key.fromUtf8(AppSettings.securityKey);  // 32 char
  static final iv = IV.fromUtf8(AppSettings.securityIv);

  static String encryptText(String text) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }
  static String decryptText(String text) {
    try {
      final encrypter = Encrypter(AES(key));
      return encrypter.decrypt64(text, iv: iv);
    } catch (e) {
      return text;
    }
  }

}