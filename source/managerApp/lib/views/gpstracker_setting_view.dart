import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/beans/device_info.dart';
import 'package:marmo/beans/marmo_info.dart';
import 'package:marmo/beans/setting_info.dart';
import 'package:marmo/components/my_popup_menu.dart' as mypopup;
import 'package:marmo/utils/db_util.dart';
import 'package:marmo/utils/shared_pre_util.dart';
import 'package:marmo/views/device_setting_view.dart';

class GpsTrackerSettingView extends StatefulWidget {
  GpsTrackerSettingView({Key key}) : super(key: key);

  @override
  GpsTrackerSettingViewState createState() => GpsTrackerSettingViewState();
}

class GpsTrackerSettingViewState extends State<GpsTrackerSettingView> {
  String title = 'marmo設定';
  final String settingUUID = '51f2e511-be4e-42e2-a502-0bf3aa109855';
  bool _blueToothFlag = false;
  List<DeviceDBInfo> dbDevices = [];
  List<DeviceInfo> myDevices = [];
  List<DeviceInfo> otherDevices = [];
  List<Widget> myDevlist = [];
  List<Widget> otherDevList = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic mCharacteristic;
  List deviceCallbackData = [];
  String password = '';
  String deviceID;

  final _codeFormat = new NumberFormat("00000", "en_US");

  final String server = "ik1-407-35954.vs.sakura.ne.jp:3000/api/v1";
  final String idKey = "ID";
  final String loginIDKey = "LoginID";
  final String keyKey = "Key";

  @override
  void initState() {
    super.initState();
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
      int result = 0xFFFFF - deviceId + 1;
      return result;
    }
  }

  void _getDeviceInfo() async {
    myDevices.clear();
    otherDevices.clear();
    dbDevices = await marmoDB.getDeviceDBInfoList();
    flutterBlue.startScan(timeout: Duration(seconds: 60));
    flutterBlue.scanResults.listen((event) {
      myDevices.clear();
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
        tempDi.count = 0;
        bool _flg = false;
        for (var i = 0; i < dbDevices.length; i++) {
          if (dbDevices[i].bleId == tempDi.id) {
            _flg = true;
            tempDi.count = dbDevices[i].count;
            tempDi.deviceDB = dbDevices[i];
//            tempDi.deviceID = int.parse(dbDevices[i].id);
            break;
          }
        }
        if (_flg) {
          myDevices.add(tempDi);
        } else if (!otherDevices.contains(tempDi)) {
          otherDevices.add(tempDi);
        }
      }
      _getOtherDevListRow();
      _getMyDevListRow();
    });
  }

  // デバイスリストアイテム作成
  void _getMyDevListRow() async {
    myDevlist.clear();
    dbDevices.forEach((db) {
      bool _flg = false;
      for (var i = 0; i < myDevices.length; i++) {
        if (myDevices[i].id.toString() == db.bleId) {
          _flg = true;
          break;
        }
      }
      if (!_flg) {
        DeviceInfo tempDi = new DeviceInfo();
        tempDi.name = db.name;
        tempDi.id = DeviceIdentifier(db.bleId);
        tempDi.device = null;
        tempDi.deviceDB = db;
        myDevices.add(tempDi);
      }
    });
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
                            padding: EdgeInsets.only(bottom: 5),
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

  void _onActionMenuSelect(Map<String, DeviceInfo> selectedVal) async {
    switch (selectedVal.keys.first) {
      case "setting":
        bool connRslt = await _deviceConnect(selectedVal.values.first);
        if (!connRslt) {
          return;
        }
        int settingCode = 0;
        if (selectedVal.values.first.count < 2) {
          if (selectedVal.values.first.count == 1) {
            settingCode = _getSettingCode(
                int.parse(selectedVal.values.first.deviceDB.id));
          }
          if (selectedVal.values.first.count == 0) {
            settingCode = _getSettingCode(null);
          }
          showAlert(context, selectedVal.values.first,
              _codeFormat.format(settingCode % 100000));
        } else {
          _deviceSet(selectedVal.values.first);
        }
        break;
      case "delete":
        // 削除処理
        _deviceDelete(selectedVal.values.first);
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
                ],
                onSelected: _onActionMenuSelect,
              ),
            ],
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

  void dataCallbackDevice() async {
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

  Future<bool> _deviceConnect(DeviceInfo deviceInfo) async {
    bool deviceFound = false;
    mCharacteristic = null;
    await deviceInfo.device.device
        .connect(autoConnect: false, timeout: Duration(seconds: 10))
        .whenComplete(() async {
      List<BluetoothService> services =
          await deviceInfo.device.device.discoverServices();
      for (BluetoothService service in services) {
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic characteristic in characteristics) {
          if (characteristic.uuid.toString() == settingUUID) {
            mCharacteristic = characteristic;
            dataCallbackDevice();
          }
        }
      }
      if (mCharacteristic == null) {
        _outputInfo("", "デバイスペアリング失敗");
        deviceInfo.device.device.disconnect();
        deviceFound = false;
      } else {
        deviceFound = true;
      }
    }).catchError((e) {
      _outputInfo("", "デバイスペアリング失敗");
      deviceInfo.device.device.disconnect();
      deviceFound = false;
    });
    return deviceFound;
  }

  void _deviceSet(DeviceInfo deviceInfo) {
    SettingInfo temp = null;
    if (mCharacteristic == null) {
      _outputInfo("", "デバイスペアリング失敗");
      deviceInfo.device.device.disconnect();
    } else {
      if (deviceCallbackData != null && deviceCallbackData.length > 0) {
        MarmoInfo de = _convertListToMap(deviceCallbackData);
        temp = new SettingInfo();
        temp.name = de.name;
        temp.sex = de.sex;
        temp.birthday = new DateTime(
            int.parse(de.birthday.substring(0, 4)),
            int.parse(de.birthday.substring(4, 2)),
            int.parse(de.birthday.substring(6, 2)));
        temp.humidity = de.humidity;
        temp.key = de.key;
        temp.interval = de.interval;
        temp.validays = de.validays;
        deviceID = de.id;
        if (deviceID.length > 5) {
          temp.id = deviceID.substring(0, deviceID.length - 5);
        } else {
          // 来ないはず
          temp.id = deviceID;
        }
        password = de.password;
      } else {
        // deviceID = _newID();
      }
      // 設定画面へ遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DeviceSettingView(deviceInfo: deviceInfo, settingInfo: temp),
        ),
      ).then((result) async {
        if (result != null) {
          String username = await spUtil.GetUsername();
          DeviceDBInfo temp = new DeviceDBInfo();
          deviceID = result.id + _newID().toString();
          temp.id = deviceID;
          temp.name = deviceInfo.name;
          temp.key = result.key;
          temp.userName = result.name;
          temp.state = 0;
          temp.bleId = deviceInfo.id.toString();
          if (deviceInfo.count == 0) {
            String url = 'http://' + server + '/device';
            Map<String, String> headers = {"Content-type": "application/json"};
            var apiJson = {
              idKey: deviceID,
              loginIDKey: username,
              keyKey: result.key
            };
            http.Response response = await http.post(url,
                headers: headers, body: json.encode(apiJson));
            if (response.statusCode == 200) {
              var dbResult = json.decode(response.body);
              password = dbResult['TemporaryPassword'];
              temp.count = 1;
              temp.password = password;
              marmoDB.insertDeviceDBInfo(temp);
            } else {
              _outputInfo("", "サーバと接続失敗");
    }
          } else {
            temp.count = 2;
            temp.password = password;
            marmoDB.updateDeviceDBInfo(temp);
          }
          Map<String, dynamic> data = new Map<String, dynamic>();
          data['id'] = deviceID;
          data['name'] = result.name;
          data['sex'] = result.sex;
          data['birthday'] = DateFormat('yyyyMMdd').format(result.birthday);
          data['alert humidity'] = result.humidity;
          data['key'] = result.key;
          data['publish interval'] = result.interval;
          data['expiration date'] = result.validays;
          data['temporary password'] = password;
          String jsonResult = json.encode(data);
          List<int> listResult = jsonResult.codeUnits;
          mCharacteristic.write(listResult);
          mCharacteristic = null;
          deviceID = null;
          password = null;
          deviceInfo.device.device.disconnect();
          Navigator.of(context).pushNamed('Setting');
        }
      });
    }
  }

  void _deviceDelete(DeviceInfo deviceInfo) async {
    String url = 'http://' + server + '/device';
    Map<String, String> headers = {"Content-type": "application/json"};
    var apiJson = {idKey: deviceInfo.deviceDB.id};
    Dio dio = new Dio();
    Response response = await dio.request(url,
        data: apiJson, // httpのbody
        options: new Options(method: 'delete', headers: headers));
    if (response.statusCode == 200) {
      marmoDB.deleteDeviceDBInfo(deviceInfo.deviceDB.id);
      Navigator.of(context).pushNamed('Setting');
    } else {
      _outputInfo("", "サーバと接続失敗");
    }
  }

  void showAlert(
      BuildContext context, DeviceInfo deviceInfo, String settingCode) {
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

  MarmoInfo _convertListToMap(List<int> list) {
    Uint8List bytes = Uint8List.fromList(list);
    String jsonString = String.fromCharCodes(bytes);
    Map<String, dynamic> temp = new Map<String, dynamic>();
    temp = json.decode(jsonString);
    MarmoInfo result = new MarmoInfo();
    result.id = temp['id'];
    result.name = temp['name'];
    result.sex = temp['sex'];
    result.birthday = temp['birthday'];
    result.humidity = temp['alert humidity'];
    result.key = temp['key'];
    result.interval = temp['publish interval'];
    result.validays = temp['expiration date'];
    result.password = temp['temporary password'];
    return result;
  }

  int _newID() {
    var rng = new Random();
    int result = rng.nextInt(100000);
    while (result < 10000) {
      result = rng.nextInt(100000);
    }
    return result;
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
              "marmoを設定するときはBluetoothをONにしてください。",
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
