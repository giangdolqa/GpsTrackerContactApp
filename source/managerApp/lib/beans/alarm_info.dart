// 緊急通知
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';

class AlarmInfo {
  String name; // ユーザー名称
  int sex; // 0:未知 1:男性 2:女性
  int age; // 年齢
  Position position; //　位置
  double bodyTemp; //　体温
  double riskRate; //　リスクレート

  AlarmInfo jsonToUserinfo(String jsonString, BuildContext context) {
    AlarmInfo userInfo;

    JsonDecoder jd = new JsonDecoder();
    try {
      userInfo = jd.convert(jsonString);
    } catch (e) {
      if (context != null) {
        Toast.show("データ転換失敗: " + e.toString(), context);
      }
      return null;
    }
    return userInfo;
  }
}
