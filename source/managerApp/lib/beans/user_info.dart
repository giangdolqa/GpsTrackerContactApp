import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';

class UserInfo {
  String name; // ユーザー名称
  int sex; // 0:未知 1:男性 2:女性
  int age; // 年齢
  Position position; //　位置
  double bodyTemp; //　体温
  double riskRate; //　リスクレート

  UserInfo jsonToUserinfo(String jsonString, BuildContext context) {
    UserInfo userInfo;

    JsonDecoder jd = new JsonDecoder();
    try {
      userInfo = jd.convert(jsonString);
    } catch (e) {
      Toast.show("データ転換失敗: " + e.toString(), context);
      return null;
    }
    return userInfo;
  }
}
