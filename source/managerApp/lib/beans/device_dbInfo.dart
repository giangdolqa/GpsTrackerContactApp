// 通常情報
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_blue/gen/flutterblue.pb.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';


class DeviceDBInfo {
  String id; // デバイスID
  String name; // 名称
  String key; // 暗号キー
  String userName; // ユーザー名称
  num state;  // 接続状態
  num count;  // 設定次数
  String bleId; // BLEID
  String password; // 一時パスワード

  /// Map
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device_id'] = this.id;
    data['name'] = this.name;
    data['key'] = this.key;
    data['username'] = this.userName;
    data['state'] = this.state;
    data['setting_count'] = this.count;
    data['ble_id'] = this.bleId;
    data['password'] = this.password;
    return data;
  }

  void fromMap(Map<String, dynamic> inputMap){
    id = inputMap['device_id'];
    name = inputMap['name'];
    key = inputMap['key'];
    userName = inputMap['username'];
    state = inputMap['state'];
    count = inputMap['setting_count'];
    bleId = inputMap['ble_id'];
    password = inputMap['password'];
  }
}
