//　暗号化&復号化ツール

import 'package:encrypt/encrypt.dart';

class CryptUtil {
  static String encrypt(String plainText, String aes256Key) {
    // 32 length key
    final key = Key.fromUtf8(aes256Key);
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
    final encryptBytes = encrypter.encrypt(plainText);
    final encrypted = encryptBytes.base64;
    return encrypted;
  }

  static String decrypt(String encryptedText, String aes256Key) {
    // 32 length key
    final key = Key.fromUtf8(aes256Key);
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
    Encrypted encryptedBytes = Encrypted.from64(encryptedText);
    final decrypted = encrypter.decrypt(encryptedBytes);
    return decrypted;
  }
}
