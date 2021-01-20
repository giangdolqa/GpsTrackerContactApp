import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

class ble_data_model {
  /*
  BLE_para demo
  */
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice device;
  Map<String, ScanResult> scanResults = new Map();
  List allBleNameAry = new List();
  BluetoothCharacteristic mCharacteristic;
}

//ble_data_model
ble_data_model model = new ble_data_model();

Future<bool> getBlueToothState() async {
  return await model.flutterBlue.isOn;
}

Future<List<BluetoothDevice>> getConnectedDevices() async {
  return await model.flutterBlue.connectedDevices;
}

void startBle() async {
  // startScan
  bool isBlueToothOn = await model.flutterBlue.isOn;
  if (isBlueToothOn) {
    await model.flutterBlue.stopScan();
    model.flutterBlue.startScan(timeout: Duration(seconds: 4));
    // scanResults
    model.flutterBlue.scanResults.listen((results) {
      // ble result device
      for (ScanResult r in results) {
        model.scanResults[r.device.name] = r;
        if (r.device.name.length > 0) {
          // print('${r.device.name} found! rssi: ${r.rssi}');
          model.allBleNameAry.add(r.device.name);
          getBleScanNameAry();
        }
      }
    });
  }
}

Stream<bool> isScanning() {
  return model.flutterBlue.isScanning;
}

List getBleScanNameAry() {
  //allBleNameAry
  List distinctIds = model.allBleNameAry.toSet().toList();
  model.allBleNameAry = distinctIds;
  return model.allBleNameAry;
}

void connectionBle(int chooseBle) {
  for (var i = 0; i < model.allBleNameAry.length; i++) {
    bool isBleName = model.allBleNameAry[i].contains("bleName");
    if (isBleName) {
      ScanResult r = model.scanResults[model.allBleNameAry[i]];
      model.device = r.device;

      // stopScan
      model.flutterBlue.stopScan();

      discoverServicesBle();
    }
  }
}

void discoverServicesBle() async {
  print("ble device connected...");
  await model.device
      .connect(autoConnect: false, timeout: Duration(seconds: 10));
  List<BluetoothService> services = await model.device.discoverServices();
  services.forEach((service) {
    var value = service.uuid.toString();
    print("ALL SERVICE VALUE --- $value");
    if (service.uuid.toString().toUpperCase().substring(4, 8) == "FFF0") {
      List<BluetoothCharacteristic> characteristics = service.characteristics;
      characteristics.forEach((characteristic) {
        var valuex = characteristic.uuid.toString();
        print("ALL CHARACTERISTIC VALUE --- $valuex");
        if (characteristic.uuid.toString() ==
            "0000fff1-0000-1000-8000-xxxxxxxx") {
          print("PAIRED CHARACTERISTIC VALUE");
          model.mCharacteristic = characteristic;

          const timeout = const Duration(seconds: 30);
          Timer(timeout, () {
            dataCallbackBle();
          });
        }
      });
    }
    // do something with service
  });
}

dataCallsendBle(List<int> value) {
  model.mCharacteristic.write(value);
}

dataCallbackBle() async {
  await model.mCharacteristic.setNotifyValue(true);
  model.mCharacteristic.value.listen((value) {
    if (value == null) {
      print("BLE戻りデータ - NULL！！");
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
    print("BLE戻りデータ - $data");
  });
}

void endBle() {
  model.device.disconnect();
}
