// 通常情報
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/utils/crypt_util.dart';
import 'package:marmo/utils/db_util.dart';
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

  Future<bool> jsonToNormalinfo(
      String jsonString, String deviceName, BuildContext context) async {
    JsonDecoder jd = new JsonDecoder();
    DeviceDBInfo deviceInfo = new DeviceDBInfo();
    deviceInfo = await marmoDB.getDeviceDBInfoByDeviceName(deviceName);
    try {
      Map<String, dynamic> tmpMap = jd.convert(jsonString);

      List<String> ruleList = [];
      try {
        List tempList =  json.decoder.convert(deviceInfo.keyRule); // Deserialize
        for (var tempItem in tempList){
          ruleList.add(tempItem.toString());
        }
      } catch (e) {
        print("marmo:: jsonToNormalinfo rule convert failed : $e");
      }

      // Lat no sec
      if (ruleList.contains('Lat no sec')) {
        latNoSec = num.parse(
            CryptUtil.decrypt(tmpMap['Lat no sec'].toString(), deviceInfo.key));
      } else {
        latNoSec = tmpMap['Lat no sec'];
      }

      // Lng no sec
      if (ruleList.contains('Lng no sec')) {
        lngNoSec = num.parse(
            CryptUtil.decrypt(tmpMap['Lng no sec'].toString(), deviceInfo.key));
      } else {
        lngNoSec = tmpMap['Lng no sec'];
      }

      // TEMP
      if (ruleList.contains('TEMP')) {
        temperature = num.parse(
            CryptUtil.decrypt(tmpMap['TEMP'].toString(), deviceInfo.key));
      } else {
        temperature = tmpMap['TEMP'];
      }

      // HUM
      if (ruleList.contains('HUM')) {
        humidity = num.parse(
            CryptUtil.decrypt(tmpMap['HUM'].toString(), deviceInfo.key));
      } else {
        humidity = tmpMap['HUM'];
      }

      // Lat
      if (ruleList.contains('Lat')) {
        latitude = num.parse(
            CryptUtil.decrypt(tmpMap['Lat'].toString(), deviceInfo.key));
      } else {
        latitude = tmpMap['Lat'];
      }

      // Lng
      if (ruleList.contains('Lng')) {
        longitude = num.parse(
            CryptUtil.decrypt(tmpMap['Lng'].toString(), deviceInfo.key));
      } else {
        longitude = tmpMap['Lng'];
      }

      // Lng
      if (ruleList.contains('Lng')) {
        longitude = num.parse(
            CryptUtil.decrypt(tmpMap['Lng'].toString(), deviceInfo.key));
      } else {
        longitude = tmpMap['Lng'];
      }

      // Step
      if (ruleList.contains('Step')) {
        step = num.parse(
            CryptUtil.decrypt(tmpMap['Step'].toString(), deviceInfo.key));
      } else {
        step = tmpMap['Step'];
      }

      return true;
    } catch (e) {
      print("デバイス配信データ転換失敗: $e ");

      if (context != null) {
        Toast.show("デバイス配信データ転換失敗: " + e.toString(), context);
      }
    }
    return false;
  }
}
