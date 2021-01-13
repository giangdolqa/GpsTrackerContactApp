import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gps_tracker/beans/device_info.dart';
import 'package:gps_tracker/beans/setting_info.dart';
import 'package:gps_tracker/utils/ble_util.dart';
import 'package:gps_tracker/utils/crypt_util.dart';
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
  final String settingUUID = '51f2e511-be4e-42e2-a502-0bf3aa109855';
  bool _blueToothFlag = false;
  List<DeviceInfo> myDevices = [];
  List<DeviceInfo> otherDevices = [];
  List<Widget> myDevlist = [];
  List<Widget> otherDevList = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic mCharacteristic;
  List deviceCallbackData = [];
  final _codeFormat = new NumberFormat("000000", "en_US");

  @override
  void initState() {
    super.initState();
//    _getDeviceInfo();
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        setState(() {
          _blueToothFlag = true;
        });
        _getDeviceInfo();
      } else if (state == BluetoothState.off) {
        setState(() {
          _blueToothFlag = false;
          otherDevList = [];
          myDevlist = [];
        });
      }
    });
  }

  int _getSettingCode(int deviceId) {
    if (deviceId == null) {
      return 123456;
    } else {
      int result = 1048575 - deviceId + 1;
      return result;
    }
  }

  void _getDeviceInfo() async {
    myDevices.clear();
    otherDevices.clear();
    if (_blueToothFlag) {
      flutterBlue.startScan(timeout: Duration(seconds: 30));
      flutterBlue.scanResults.listen((event) {
        otherDevices.clear();
        for (ScanResult result in event) {
          if (result.device.name.isEmpty) {
            continue;
          }
          DeviceInfo tempDi = new DeviceInfo();
          tempDi.name = result.device.name;
          tempDi.id = result.device.id;
          tempDi.type = result.device.type;
          tempDi.device = result;
//          bool _flg = false;
//          for (var i = 0; i < otherDevices.length; i++) {
//            if (otherDevices[i].id == tempDi.id) {
//              _flg = true;
//              break;
//            }
//          }
//          if (!_flg) {
//            otherDevices.add(tempDi);
//          }
          if (!otherDevices.contains(tempDi)) {
            otherDevices.add(tempDi);
          }
        }
        _getOtherDevListRow();
      });
    } else {
      myDevices.clear();
      otherDevices.clear();
    }
//    DeviceInfo tempDi = new DeviceInfo();
//    tempDi.name = "name";
//    tempDi.id = DeviceIdentifier("123456");
//    tempDi.type = BluetoothDeviceType.classic;
//    myDevices.add(tempDi);
//    _getMyDevListRow();
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
                child: Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      // margin: EdgeInsets.fromLTRB(0, 64.0, 0, 0),
                      child: Stack(
                        children: [
                          Image(
                              image: AssetImage("assets/icon/GPS_icon.png"),
                              fit: BoxFit.fill),
                          Container(
                            padding: EdgeInsets.only(bottom:5),
                            alignment: Alignment.center,
                            child: Text(
                              device.name.substring(0, 3).toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                offset: Offset(0, 50),
                itemBuilder: (_) =>
                    <mypopup.PopupMenuItem<Map<String, DeviceInfo>>>[
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
                    value: {"setting": device},
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
//              Container(
//                padding: EdgeInsets.only(left: 10),
//                child: Text(device.name, style: TextStyle(fontSize: 14)),
//              ),
            ],
          ),
        ),
      );
    });
    if (mounted) {
      setState(() {
        myDevlist = tmpDevlist;
      });
    }
  }

  void _onActionMenuSelect(Map<String, DeviceInfo> selectedVal) {
    switch (selectedVal.keys.first) {
      case "setting":
        int settingCode = _getSettingCode(
            int.parse(selectedVal.values.first.id.toString().substring(0, 5)));
        showAlert(
            context, selectedVal.values.first, _codeFormat.format(settingCode));
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
          child: InkWell(
            onTap: () {}, //　ペアリング処理
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  // margin: EdgeInsets.fromLTRB(0, 64.0, 0, 0),
                  child: Stack(
                    children: [
                      Image(
                          image: AssetImage("assets/icon/GPS_icon.png"),
                          fit: BoxFit.fill),
                      Container(
                        padding: EdgeInsets.only(bottom:5),
                        alignment: Alignment.center,
                        child: Text(
                          device.name.substring(0, 3).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
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
        ),
      );
    });
    if (mounted) {
      setState(() {
        otherDevList = tmpDevlist;
      });
    }
  }

  dataCallbackDevice() async {
    await mCharacteristic.setNotifyValue(true);
    mCharacteristic.value.listen((value) {
      if (value == null) {
        return;
      }
      List data = [];
      for (var i = 0; i < value.length; i++) {
        String dataStr = value[i].toRadixString(16);
        if (dataStr.length < 2) {
          dataStr = "0" + dataStr;
        }
        String dataEndStr = "0x" + dataStr;
        data.add(dataEndStr);
      }
      deviceCallbackData = data;
    });
  }

  _onTapOtherDevice(DeviceInfo device) {
    device.device.device
        .connect(timeout: Duration(seconds: 60), autoConnect: false);
  }

  _deviceSet(DeviceInfo deviceInfo) {
    SettingInfo temp = null;
    deviceInfo.device.device
        .connect(autoConnect: false, timeout: Duration(seconds: 10))
        .whenComplete(() async {
      BluetoothCharacteristic mCharacteristic;
      List<BluetoothService> services =
          await deviceInfo.device.device.discoverServices();
      services.forEach((service) async {
        var characteristics = service.characteristics;
        characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == settingUUID) {
            mCharacteristic = characteristic;
            const timeout = const Duration(seconds: 10);
            Timer(timeout, () {
              dataCallbackDevice();
            });
          }
        });
      });
      if (mCharacteristic == null) {
        print("デバイスペアリングエラー");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DeviceSettingView(deviceInfo: deviceInfo, settingInfo: temp),
          ),
        ).then((result) {
          if (result != null) {
            mCharacteristic.write(result);
            deviceInfo.device.device.disconnect();
          }
        });
      }
    }).catchError(() {
      print("デバイスペアリングエラー");
    });
    // 設定画面へ遷移
  }

  showAlert(BuildContext context, DeviceInfo deviceInfo, String settingCode) {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text(deviceInfo.name + 'をペア設定しますか？'),
        content: Container(
          height: 80,
          alignment: Alignment.centerLeft,
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bluetoothペア設定コード'),
                SizedBox(height: 10.0),
                Text(
                  settingCode,
                  style: TextStyle(
                    inherit: true,
                    color: Colors.red,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ]),
        ),
        actions: <Widget>[
          new RaisedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('キャンセル'),
          ),
          new RaisedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deviceSet(deviceInfo);
            },
            child: new Text('ペア設定する'),
          ),
        ],
      ),
    );
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
//                      _initBluetoothState();
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
            child: Column(
              // shrinkWrap: true,
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
            child: Column(
              // shrinkWrap: true,
              children: otherDevList,
            ),
          ),
        ],
      ),
    );
  }
}
