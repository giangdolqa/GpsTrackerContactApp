import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';

class RPIInfo {
  List<RPIItem> rpiList = [];

  // RPI情報作成
  // TODO: デバイスIDでDB情報でのRPI情報取得し、本関数で情報文字列を処理
  void jsonToRPIInfo(String jsonString, BuildContext context) {
    rpiList.clear();
    JsonDecoder jd = new JsonDecoder();
    try {
      List rpiDataList = json.decode(jsonString);
      if (rpiDataList != null) {
        if (rpiDataList.isNotEmpty) {
          rpiDataList.forEach((dataMap) {
            RPIItem tempItem = new RPIItem();
            tempItem.time = dataMap["time"];
            tempItem.RPI = dataMap["RPI"];
            rpiList.add(tempItem);
          });
        }
      }
    } catch (e) {
      Toast.show("データ転換失敗: " + e.toString(), context);
      return null;
    }
  }
}

class RPIItem {
  String time;
  String RPI;
}
