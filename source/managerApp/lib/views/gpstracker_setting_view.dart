import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gps_tracker/beans/device_info.dart';
import 'package:gps_tracker/beans/setting_info.dart';
import 'package:gps_tracker/utils/ble_util.dart';
import 'package:gps_tracker/components/my_popup_menu.dart' as mypopup;
import 'package:gps_tracker/views/device_setting_view.dart';

import 'package:intl/intl.dart';

class GpsTrackerSettingView extends StatefulWidget {
  GpsTrackerSettingView({Key key}) : super(key: key);

  @override
  GpsTrackerSettingViewState createState() => GpsTrackerSettingViewState();
}

class GpsTrackerSettingViewState extends State<GpsTrackerSettingView> {
  String title = 'GPSトラッカー設定';
  bool _blueToothFlag = true;
  List<DeviceInfo> myDevices = [];
  List<DeviceInfo> otherDevices = [];
  List<Widget> myDevlist = [];
  List<Widget> otherDevList = [];
  Timer _timer = null;

  @override
  void initState() {
    super.initState();
    _initDeviceList();

    const timeInterval = const Duration(seconds: 1);
    _timer = Timer.periodic(timeInterval, (timer) {
      _initBluetoothState();
    });
  }

  _initDeviceList() async {
    await _getDeviceInfo();
    _getMyDevListRow();
    _getOtherDevListRow();
  }

  _initBluetoothState() async {
    bool isBluetoothOn = await getBlueToothState();
    if (mounted) {
      setState(() {
        _blueToothFlag = isBluetoothOn;
      });
    }
  }

  void _getDeviceInfo() async {
    if (_blueToothFlag) {
      startBle();
      // 接続したデバイスを取得
      List<BluetoothDevice> connectedDevices = await getConnectedDevices();
      connectedDevices.forEach((bluetoothDevice) {
        DeviceInfo tempDi = new DeviceInfo();
        tempDi.name = bluetoothDevice.name;
        tempDi.id = bluetoothDevice.id;
        tempDi.type = bluetoothDevice.type;
        myDevices.add(tempDi);
      });

      //その他のデバイスを取得
      List bleScanNameAry = getBleScanNameAry();
      bleScanNameAry.forEach((deviceName) {
        DeviceInfo tempDi = new DeviceInfo();
        tempDi.name = deviceName;
        otherDevices.add(tempDi);
      });
    } else {
      myDevices.clear();
      otherDevices.clear();
    }
  }

  // デバイスリストアイテム作成
  void _getMyDevListRow() async {
    myDevlist.clear();
    List<Widget> tmpDevlist = [];
    myDevices.forEach((device) {
      tmpDevlist.add(
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              mypopup.PopupMenuButton(
                child: Image(
                  image: AssetImage("assets/icon/GPS_icon.png"),
                  fit: BoxFit.fill,
                  height: 35,
                ),
                offset: Offset(0, 50),
                itemBuilder: (_) => <mypopup.PopupMenuItem<Map<String, DeviceInfo>>>[
                  new mypopup.PopupMenuItem<Map<String, DeviceInfo>>(
                    child: Container(
                      height: double.infinity,
                      width: 120,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: Icon(
                              Icons.settings,
                              size: 30,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 5, top: 5),
                              child: Text(
                                "設定",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              // alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    color: Color(0x55c4c4c4),
                    value: {"setting":device},
                  ),
                  new mypopup.PopupMenuItem<Map<String, DeviceInfo>>(
                    child: Container(
                      height: double.infinity,
                      width: 120,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: Image.asset(
                              "assets/icon/dust.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 5, top: 5),
                              child: Text(
                                "削除",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              // alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    value: {"delete": device},
                  ),
                ],
                onSelected: _onActionMenuSelect,
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(device.name, style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      );
    });
    setState(() {
      myDevlist = tmpDevlist;
    });
  }

  void _onActionMenuSelect(Map<String, DeviceInfo> selectedVal) {
    switch (selectedVal.keys.first) {
      case "setting":
        SettingInfo temp = null;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceSettingView(deviceInfo: selectedVal.values.first, settingInfo: temp),
          ),
        ).then((result) {});
        // 設定画面へ遷移
        break;
      case "delete":
        // 削除処理
        break;
      default:
        // do nothing
        break;
    }
    return;
  }

  void _getOtherDevListRow() async {
    otherDevList.clear();
    List<Widget> tmpDevlist = [];
    otherDevices.forEach((device) {
      tmpDevlist.add(
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              mypopup.PopupMenuButton(
                      child: Image(
                          image: AssetImage("assets/icon/GPS_icon.png"),
                  fit: BoxFit.fill,
                  height: 35,
                ),
                offset: Offset(0, 50),
                itemBuilder: (_) => <mypopup.PopupMenuItem<Map<String, DeviceInfo>>>[
                  new mypopup.PopupMenuItem<Map<String, DeviceInfo>>(
                    child: Container(
                      height: double.infinity,
                      width: 120,
                      child: Row(
                        children: [
              Container(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: Icon(
                              Icons.settings,
                              size: 30,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 5, top: 5),
                              child: Text(
                                "設定",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              // alignment: Alignment.center,
                                ),
                          ),
                        ],
                      ),
                    ),
                    color: Color(0x55c4c4c4),
                    value: {"setting":device},
                  ),
                  new mypopup.PopupMenuItem<Map<String, DeviceInfo>>(
                            child: Container(
                      height: double.infinity,
                      width: 120,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: Image.asset(
                              "assets/icon/dust.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 5, top: 5),
                              child: Text(
                                "削除",
                                style: TextStyle(
                                  fontSize: 18,
                              ),
                              ),
                              // alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    value: {"delete": device},
                  ),
                ],
                onSelected: _onActionMenuSelect,
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  device.name,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    });
    setState(() {
      otherDevList = tmpDevlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 15,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              "GPSトラッカーを設定するときはBluetoothをONにしてください。",
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              children: [
                Text(
                  "Bluetooth",
                  style: TextStyle(fontSize: 14),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Switch(
                    value: _blueToothFlag,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      AppSettings.openBluetoothSettings();
                      _initBluetoothState();
                      // setState(() {
                      //   _blueToothFlag = value;
                      // });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              "自分のデバイス",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Container(
            // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Divider(
              color: Colors.blue.withOpacity(0.3),
              thickness: 2,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: ListView(
              shrinkWrap: true,
              children: myDevlist,
            ),
          ),
          Container(
            // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              "その他のデバイス",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Container(
            // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Divider(
              color: Colors.blue.withOpacity(0.3),
              thickness: 2,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: ListView(
              shrinkWrap: true,
              children: otherDevList,
            ),
          ),
        ],
      ),
    );
  }
}
