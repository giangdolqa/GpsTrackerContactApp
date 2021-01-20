// 通常情報

import 'package:flutter_blue/flutter_blue.dart';

import 'device_dbInfo.dart';

class DeviceInfo {
  String name; // 名称
  DeviceIdentifier id; // ハードウェアID
  BluetoothDeviceType type;
  ScanResult device;
  DeviceDBInfo deviceDB;
  int count;
}
