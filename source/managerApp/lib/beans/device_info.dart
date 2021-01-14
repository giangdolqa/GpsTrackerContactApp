// 通常情報
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_blue/gen/flutterblue.pb.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';

import 'device_dbInfo.dart';


class DeviceInfo {
  String name; // 名称
  DeviceIdentifier id; // ハードウェアID
  BluetoothDeviceType type;
  ScanResult device;
  DeviceDBInfo deviceDB;
  int count;
}
