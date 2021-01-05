import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_tracker/beans/device_info.dart';

import 'package:intl/intl.dart';

class GpsTrackerSettingView extends StatefulWidget {
  GpsTrackerSettingView({Key key}) : super(key: key);

  @override
  GpsTrackerSettingViewState createState() => GpsTrackerSettingViewState();
}

class GpsTrackerSettingViewState extends State<GpsTrackerSettingView> {
  String title = 'GPSトラッカー設定';
  bool _blueToothFlag = false;
  List<DeviceInfo> myDevices = [];
  List<DeviceInfo> otherDevices = [];
  List<Widget> myDevlist = [];
  List<Widget> otherDevList = [];

  @override
  void initState() {
    super.initState();
    getMyDevListRow();
    getOtherDevListRow();
  }

  // デバイスリストアイテム作成
  void getMyDevListRow() async {
    myDevlist.clear();
    List<Widget> tmpDevlist = [];
    // myDevices = .. TODO:  ペアリング済み設備取得
    // DeviceInfo di = new DeviceInfo();
    // di.name = "aaa";
    // di.HID = "bbb";
    // myDevices.add(di);
    myDevices.forEach((device) {
      tmpDevlist.add(
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Text(device.name, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    });
    setState(() {
      myDevlist = tmpDevlist;
    });
  }

  void getOtherDevListRow() async {
    otherDevList.clear();
    List<Widget> tmpDevlist = [];
    // myDevices = .. TODO:  ペアリング済み設備取得
    DeviceInfo di = new DeviceInfo();
    di.name = "aaa";
    di.HID = "bbb";
    otherDevices.add(di);
    otherDevices.forEach((device) {
      tmpDevlist.add(
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Text(device.name, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    });
    setState(() {
      myDevlist = tmpDevlist;
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
                      setState(() {
                        _blueToothFlag = value;
                      });
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
            padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
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
            padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
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
