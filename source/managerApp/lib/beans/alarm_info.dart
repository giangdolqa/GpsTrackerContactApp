// 緊急通知
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';

class AlarmInfo {
  num Sex; // 0:未知 1:男性 2:女性
  num Age; // 年齢
  num Lat; // 経度
  num Lng; // 緯度
  Position position; //　位置

  AlarmInfo jsonStrToAlarminfo(String jsonString, BuildContext context) {
    JsonDecoder jd = new JsonDecoder();
    try {
      Map<String, dynamic> tmpMap = jd.convert(jsonString);
      Sex = tmpMap["Sex"];
      Age = tmpMap["Age"];
      Lat = tmpMap["Lat"];
      Lng = tmpMap["Lng"];
      position = Position(latitude: Lat, longitude: Lng);
    } catch (e) {
      if (context != null) {
        Toast.show("データ転換失敗: " + e.toString(), context);
      }
      return null;
    }
  }
}
