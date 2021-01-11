// 通常情報
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_blue/gen/flutterblue.pb.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';


class DeviceDBInfo {
  String id; // ハードウェアID
  String name; // 名称
  String key; // 暗号キー
  String userName; // ユーザー名称
  num state;  // 接続状態

  /// Map
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['key'] = this.key;
    data['userName'] = this.userName;
    data['state'] = this.state;
    return data;
  }
}
