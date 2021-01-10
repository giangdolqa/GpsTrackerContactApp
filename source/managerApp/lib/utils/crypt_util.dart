//　暗号化&復号化ツール
import 'dart:convert';

import 'package:encrypt/encrypt.dart';

class CryptUtil {
  static String encrypt(String plainText, String aes256Key) {
    // 32 length key
    final key = Key.fromUtf8(aes256Key);
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
    final encrypted = encrypter.encrypt(plainText).base16;
    return encrypted;
  }

  static String decrypt(String encryptedText, String aes256Key) {
    // 32 length key
    final key = Key.fromUtf8(aes256Key);
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
    final text =
        "A set of high-level APIs over PointyCastle for two-way cryptography.";
    Encrypted encryptedBytes = Encrypted.fromUtf8(encryptedText);
    final decrypted = encrypter.decrypt(encryptedBytes);
    return decrypted;
  }
}
