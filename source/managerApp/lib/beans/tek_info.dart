import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';

class TEKInfo {
  List<TEKItem> tekList = [];

  // TEK情報作成
  // TODO: デバイスIDでDB情報でのTEK情報取得し、本関数で情報文字列を処理
  TEKInfo jsonToTEKInfo(String jsonString, BuildContext context) {
    tekList.clear();
    try {
      List tekDataList = json.decode(jsonString);
      if (tekDataList != null) {
        if (tekDataList.isNotEmpty) {
          tekDataList.forEach((dataMap) {
            TEKItem tempItem = new TEKItem();
            tempItem.time = dataMap["time"];
            tempItem.TEK = dataMap["TEK"];
            List tempEninList = dataMap["ENIN"];
            List<String> tempStrList = [];
            tempEninList.forEach((dataItem) {
              tempStrList.add(dataItem.toString());
            });
            tempItem.ENINList = tempStrList;
            tekList.add(tempItem);
          });
        }
      }
    } catch (e) {
      Toast.show("データ転換失敗: " + e.toString(), context);
      return null;
    }
  }
}

class TEKItem {
  String time;
  String TEK;
  List<String> ENINList;
}
