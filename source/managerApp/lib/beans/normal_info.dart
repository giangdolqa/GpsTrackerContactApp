// 通常情報
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';

class NormalInfo {
  double latNoSec; // “Lat no sec”:秒を切り捨てた緯度,
  double lngNoSec; // “Lng no sec”:秒を切り捨てた経度,
  double temperature; // “TEMP”:温度,
  double humidity; // “HUM”:湿度,
  double latitude; // “Lat”:緯度,
  double longitude; // “Lng”:経度,
  int step; // “Step”:歩数,

  String name; // 顧客名称
  String description; // 地図表示用詳細情報

  NormalInfo jsonToUserinfo(String jsonString, BuildContext context) {
    NormalInfo userInfo;

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
