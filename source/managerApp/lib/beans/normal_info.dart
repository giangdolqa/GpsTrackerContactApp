// 通常情報
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/utils/crypt_util.dart';
import 'package:marmo/utils/db_util.dart';
import 'package:marmo/utils/mqtt_util.dart';
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
    try {
      deviceInfo = await marmoDB.getDeviceDBInfoByDeviceName(deviceName);
      String nowDate = formatDate(DateTime.now(), [yyyy, mm, dd]);
      if (deviceInfo.keyDate != nowDate){
        deviceInfo.key = await mqttUtil.getEncryptKey(deviceInfo.name);
        if (deviceInfo.key == null){
          return false;
        }
      }
    } catch (e) {
      print("marmo:: jsonToNormalinfo failed $e");
      return false;
    }

    try {
      Map<String, dynamic> tmpMap = jd.convert(jsonString);
      latNoSec = tmpMap['Lat no sec'];
      lngNoSec = tmpMap['Lng no sec'];
      temperature = tmpMap['TEMP'];
      humidity = tmpMap['HUM'];
      latitude = num.parse(
          CryptUtil.decrypt(tmpMap['Lat'].toString(), deviceInfo.key));
      longitude = num.parse(
          CryptUtil.decrypt(tmpMap['Lng'].toString(), deviceInfo.key));
      step = num.parse(
          CryptUtil.decrypt(tmpMap['Step'].toString(), deviceInfo.key));
      return true;
    } catch (e) {
      print("緊急通知データ転換失敗: $e ");

      if (context != null) {
        Toast.show("緊急通知データ転換失敗: " + e.toString(), context);
      }
    }
    return false;
  }
}
