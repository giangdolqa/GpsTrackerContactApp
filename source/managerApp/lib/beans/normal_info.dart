// 通常情報
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';

class NormalInfo {
  num latNoSec; // “Lat no sec”:秒を切り捨てた緯度,
  num lngNoSec; // “Lng no sec”:秒を切り捨てた経度,
  num temperature; // “TEMP”:温度,
  num humidity; // “HUM”:湿度,
  num latitude; // “Lat”:緯度,
  num longitude; // “Lng”:経度,
  num step; // “Step”:歩数,

  String name; // 顧客名称
  String description; // 地図表示用詳細情報

  NormalInfo jsonToNormalinfo(String jsonString, BuildContext context) {
    JsonDecoder jd = new JsonDecoder();
    try {
      Map<String, dynamic> tmpMap = jd.convert(jsonString);
      latNoSec = tmpMap['Lat no sec'];
      lngNoSec = tmpMap['Lng no sec'];
      temperature = tmpMap['TEMP'];
      humidity = tmpMap['HUM'];
      latitude = tmpMap['Lat'];
      longitude = tmpMap['Lng'];
      step = tmpMap['Step'];
    } catch (e) {
      if (context != null) {
        Toast.show("データ転換失敗: " + e.toString(), context);
      }
      return null;
    }
  }
}
