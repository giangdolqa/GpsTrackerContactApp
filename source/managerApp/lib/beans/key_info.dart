import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';

class KeyInfo {
  String type; // タイプ
  List name; // 名所
  String key; // キー+暗号鍵

  KeyInfo jsonToKeyInfo(String jsonString, BuildContext context) {
    JsonDecoder jd = new JsonDecoder();
    try {
      Map<String, dynamic> tmpMap = jd.convert(jsonString);
      type = tmpMap['type'];
      name = tmpMap['name'];
      key = tmpMap['key'];
    } catch (e) {
      if (context != null) {
        Toast.show("データ転換失敗: " + e.toString(), context);
      }
      return null;
    }
    return this;
  }

  // キーハッシュ化
  String getHashedKey(String topicStr) {
    try {
      String dateStr = topicStr.split("/")[2];
      // ①	時刻のDDの２文字目+1文字分、時刻を切り出す。
      num trimNum = num.parse(dateStr.substring(7,8)) + 1;
      String hashKey = dateStr.substring(0, trimNum);
      // ②	その切り出した文字をキーとして、SHA256ハッシュ化する。
      var bytes = utf8.encode(hashKey);
      var hashedKeySha256 = sha256.convert(bytes);
      String hexKeyStr = hashedKeySha256.toString();
      return hexKeyStr;
    }
    catch (e){
      print("getHashedKey failed: $e");
      return null;
    }

  }
}
