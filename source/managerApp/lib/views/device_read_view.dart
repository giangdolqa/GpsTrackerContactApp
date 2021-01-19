import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/beans/device_info.dart';
import 'package:marmo/utils/db_util.dart';
import 'package:marmo/utils/shared_pre_util.dart';

class GpsTrackerReadingView extends StatefulWidget {
  GpsTrackerReadingView({Key key}) : super(key: key);

  @override
  GpsTrackerReadingViewState createState() => GpsTrackerReadingViewState();
}

class GpsTrackerReadingViewState extends State<GpsTrackerReadingView> {
  String title = 'marmo読み込み';
  final String TEKENIN_UUID = '88b9d302-1d53-4743-af14-ccb68179fa75';
  final String RPIAEM_UUID = 'b9428273-c634-491c-9e0a-f3ec17cefbc9';
  bool _blueToothFlag = false;
  List<DeviceDBInfo> myDBDevicesList = [];
  List<Widget> myDevlist = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic mCharacteristic_TEK;
  BluetoothCharacteristic mCharacteristic_RPI;
  List deviceCallbackData = [];
  Map<String, bool> connectStatusMap = {};
  Map<String, BluetoothDevice> connectedDevice = {};
  String tmpConnectStr = "";

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
          myDevlist = [];
        });
      }
    });
    // 接続済みデバイス取得
    flutterBlue.stopScan();
    _getDeviceListFromDB();
  }

  // _initDB() async {
  //   // await marmoDB.DropDb();
  //   await marmoDB.intializeDatabase();
  // }

  // デバイスリストをDBから取得
  void _getDeviceListFromDB() async {
    List<DeviceDBInfo> tempDBList = await marmoDB.getDeviceDBInfoList();
    myDBDevicesList.clear();
    for (DeviceDBInfo dbInfo in tempDBList) {
      bool _flg = false;
      for (var i = 0; i < myDBDevicesList.length; i++) {
        if (myDBDevicesList[i].id == dbInfo.id) {
          _flg = true;
          break;
        }
      }
      if (!_flg) {
        myDBDevicesList.add(dbInfo);
      }
    }
    for (var deviceInfo in myDBDevicesList) {
      // 接続状態初期化
      connectStatusMap[deviceInfo.id] = false;
    }
  }

  // デバイス情報更新
  void _getDeviceInfo() async {
    setState(() {
      connectStatusMap.forEach((key, value) {
        value = false;
      });
    });
    if (_blueToothFlag) {
      flutterBlue.startScan(timeout: Duration(seconds: 30));
      flutterBlue.scanResults.listen((event) async {
        for (ScanResult result in event) {
          if (result.device.name.isEmpty) {
            continue;
          }

          // DEBUG -S-
          // DeviceDBInfo temp = new DeviceDBInfo();
          // temp.id = result.device.id.toString();
          // temp.name = result.device.name;
          // temp.key = "0123456789123456";
          // temp.keyDate = "2020/01/18";
          // temp.userName = "鈴谷　カモメ";
          // temp.state = 0;
          // temp.bleId = result.device.id.toString();
          // temp.count = 2;
          // temp.password = "0123456789123456";
          // marmoDB.insertDeviceDBInfo(temp);
          // DEBUG -E-
          for (DeviceDBInfo dbDveice in myDBDevicesList) {
            if (dbDveice.id == result.device.id.id) {
              if (mounted) {
                setState(() {
                  connectStatusMap[result.device.id.id] = true;
                  connectedDevice[result.device.id.id] = result.device;
                });
              }
            }
          }
          _getMyDevListRow();
        }
      });
    }
  }

  // スマホアイテム作成(ご自分）
  Future<Widget> getMyPhoneItem() async {
    String userName = await spUtil.GetUsername();
    if (userName == null) {
      userName = "";
    }
    userName = userName + "（ご自分）";
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 40,
            // margin: EdgeInsets.fromLTRB(0, 64.0, 0, 0),
            child: Image(
                image: AssetImage("assets/icon/phone.png"),
                fit: BoxFit.fitHeight),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                userName,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          InkWell(
            child: Container(
              width: 35,
              height: 35,
              child: Image(
                  image: AssetImage("assets/icon/confirm.png"),
                  fit: BoxFit.fill),
            ),
            onTap: () {}, // TODO: 接触確認画面へ遷移
          ),
        ],
      ),
    );
  }

  // デバイスリストアイテム作成
  void _getMyDevListRow() async {
    myDevlist.clear();
    List<Widget> tmpDevlist = [];
    Widget myPhone = await getMyPhoneItem();
    tmpDevlist.add(myPhone);
    myDBDevicesList.forEach((device) {
      tmpDevlist.add(
        Container(
          padding: EdgeInsets.all(5),
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
                      padding: EdgeInsets.only(bottom: 5),
                      alignment: Alignment.center,
                      child: Text(
                        "GPS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 顧客名称
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    device.userName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              // 接続状態
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    connectStatusMap[device.id] ? "接続済み" : "未接続",
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // 読み込みボタン
              InkWell(
                child: Container(
                  width: 40,
                  height: 35,
                  padding: EdgeInsets.only(left: 5),
                  child: connectStatusMap[device.id]
                      ? Image(
                          image: AssetImage("assets/icon/refresh.png"),
                          fit: BoxFit.fill)
                      : Container(),
                ),
                onTap: connectStatusMap[device.id]
                    ? () {
                        _deviceRead(connectedDevice[device.id]);
                      }
                    : null,
              ),
              // 接触確認ボタン
              InkWell(
                child: Container(
                  width: 40,
                  height: 35,
                  padding: EdgeInsets.only(left: 5),
                  child: connectStatusMap[device.id]
                      ? Image(
                          image: AssetImage("assets/icon/confirm.png"),
                          fit: BoxFit.fill)
                      : Container(),
                ),
                onTap: connectStatusMap[device.id]
                    ? () {} // TODO: 接触確認画面へ遷移
                    : null,
              ),
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

  // TEK/EINN情報読み込み
  _readTEKInfo(BluetoothDevice deviceInfo) async {
    await mCharacteristic_TEK.setNotifyValue(true);
    List<int> tekInfoInts = await mCharacteristic_TEK.read();
    String tekStr = String.fromCharCodes(tekInfoInts);
    // DBを更新
    DeviceDBInfo dbInfo =
        await marmoDB.getDeviceDBInfoByDeviceId(deviceInfo.id.id);
    if (dbInfo != null) {
      dbInfo.tekInfo = tekStr;
      marmoDB.updateDeviceDBInfo(dbInfo);
    }
  }

  // RPI/AEM情報読み込み
  _readRPIInfo(BluetoothDevice deviceInfo) async {
    await mCharacteristic_RPI.setNotifyValue(true);
    List<int> rpiInfoInts = await mCharacteristic_RPI.read();
    String rpiStr = String.fromCharCodes(rpiInfoInts);
    // DBを更新
    DeviceDBInfo dbInfo =
        await marmoDB.getDeviceDBInfoByDeviceId(deviceInfo.id.id);
    if (dbInfo != null) {
      dbInfo.rpiInfo = rpiStr;
      marmoDB.updateDeviceDBInfo(dbInfo);
    }
  }

  _onTapOtherDevice(DeviceInfo device) {
    device.device.device
        .connect(timeout: Duration(seconds: 60), autoConnect: false);
  }

  _outputInfo(String iTitle, String iErrInfo) {
    Widget cancelButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(iTitle),
      content: Text(iErrInfo),
      actions: [
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _deviceRead(BluetoothDevice deviceInfo) {
    // DEBUG -S-
    // RPI test
    // List<Map<String, dynamic>>tmpList = [
    //   {
    //     "time": "20210115091123",
    //     "RPI": "a07d635658f82c3c4b8fb211f1e0634"
    //   },
    //   {
    //     "time": "20210115091123",
    //     "RPI": "a07d635658f82c3c4b8fb211f1e0634"
    //   }
    // ];
    // String jsonString = json.encode(tmpList);
    // RPIInfo rpiInfo = new RPIInfo();
    // rpiInfo.jsonToRPIInfo(jsonString, context);

    // tek test
    // List<Map<String, dynamic>>tmpList = [
    //   {
    //     "time": "20210115091123",
    //     "TEK": "a07d635658f82c3c4b8fb211f1e0634",
    //     "ENIN":["5fe5bedc", "5fe5c1ac"]
    //   },
    //   {
    //     "time": "20210115091123",
    //     "TEK": "a07d635658f82c3c4b8fb211f1e0634",
    //     "ENIN":["5fe5bedc", "5fe5c1ac"]
    //   }
    // ];
    // String jsonString = json.encode(tmpList);
    // TEKInfo tekInfo = new TEKInfo();
    // tekInfo.jsonToTEKInfo(jsonString, context);

    // marmoDB.DropDb();
    // marmoDB.intializeDatabase();
    // DEBUG -E-
    deviceInfo
        .connect(autoConnect: true, timeout: Duration(seconds: 10))
        .whenComplete(() async {
      List<BluetoothService> services = await deviceInfo.discoverServices();
      services.forEach((service) async {
        var characteristics = service.characteristics;
        characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == TEKENIN_UUID) {
            mCharacteristic_TEK = characteristic;
            const timeout = const Duration(seconds: 10);
            Timer(timeout, () async {
              await _readTEKInfo(deviceInfo);
            });
          } else if (characteristic.uuid.toString() == RPIAEM_UUID) {
            mCharacteristic_RPI = characteristic;
            const timeout = const Duration(seconds: 10);
            Timer(timeout, () async {
              await _readRPIInfo(deviceInfo);
            });
          }
        });
        _outputInfo("", "読み込み成功");
        deviceInfo.disconnect();
      });
      if (mCharacteristic_TEK == null || mCharacteristic_RPI == null) {
        _outputInfo("", "読み込み失敗");
        deviceInfo.disconnect();
      }
    }).catchError((error) {
      _outputInfo("", "読み込み失敗");
      deviceInfo.disconnect();
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
              "marmoからデータを詠み込む時はBluetoothをONにしてください。",
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
        ],
      ),
    );
  }
}
