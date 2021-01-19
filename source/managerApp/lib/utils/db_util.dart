//　ローカルDB
import 'dart:async';
import 'dart:io';

import 'package:marmo/beans/device_dbInfo.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final marmoDB = new DbUtil();

class DbUtil {
  static DbUtil dbUtil; //Singleton DbUtil
  static Database _database; //Singleton Database

//Database table name along with column name
  String deviceInfoTable = 'deviceInfo_table';
  String colId = 'id'; //　Id
  String colDeviceId = 'device_id'; //　DeviceId
  String colDeviceName = 'name'; // デバイス名
  String colDeviceKey = 'key'; // 暗号キー
  String colState = 'state'; // 設定済みステート 0:未 1:済み
  String colUserName = 'username'; // ユーザー名称
  String colCount = 'setting_count'; // 設定次数
  String colBleId = 'ble_id'; // bluetoothID
  String colPassword = 'password'; // 一時パスワード
  String colTEKInfo = 'tek_enin'; // TEK/ENIN情報文字列
  String colRPIInfo = 'rpi_aem'; // RPI/AEM情報文字列

  DbUtil._createInstance();

  factory DbUtil() {
    if (dbUtil == null) {
      dbUtil = DbUtil._createInstance();
    }

    return dbUtil;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await intializeDatabase();
    }
    return _database;
  }

  Future<Database> intializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
      String path = join(directory.path, 'deviceInfo.db');
    //
    // File file = File(path);
    // if (file != null){
    //   file.delete();
    // }
    var deviceInfoDatabase =
        openDatabase(path, version: 1, onCreate: _createDb);
    return deviceInfoDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $deviceInfoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colDeviceId TEXT, $colDeviceName TEXT, '
        '$colDeviceKey TEXT, $colState INTEGER, $colUserName TEXT, $colCount INTEGER, $colBleId TEXT, $colPassword TEXT, $colTEKInfo TEXT, $colRPIInfo TEXT)');
  }

  void DropDb() async {
    Database db = await this.database;
    await db.execute(
        'DROP TABLE $deviceInfoTable');
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'deviceInfo.db');
    File file = File(path);
    if (file != null){
      file.delete();
    }
  }

//Fetch Operation :Get all object from database
  Future<List<Map<String, dynamic>>> getDeviceDBInfoMapList() async {
    Database db = await this.database;


//var result= db.rawQuery('SELECT * FROM $deviceInfoTable order by $colState ASC');
    var result = db.query(deviceInfoTable, orderBy: '$colId ASC');
    return result;
  }

  Future<List<DeviceDBInfo>> getDeviceDBInfoList() async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(deviceInfoTable, orderBy: '$colId ASC');
    List<DeviceDBInfo> dbInfoList = [];
    result.forEach((element) {
      DeviceDBInfo tempInfo = DeviceDBInfo();
      tempInfo.fromMap(element);
      dbInfoList.add(tempInfo);
    });
    return dbInfoList;
  }

//Insert Operation :Insert a DeviceDBInfoboject to database

  Future<int> insertDeviceDBInfo(DeviceDBInfo di) async {
    Database db = await this.database;
    var result = await db.insert(deviceInfoTable, di.toMap());
    return result;
  }

//Update Operation :Update a DeviceDBInfo object and save it to Database
  Future<int> updateDeviceDBInfo(DeviceDBInfo deviceInfo) async {
    var db = await this.database;
    var result = await db.update(deviceInfoTable, deviceInfo.toMap(),
        where: '$colDeviceId =?', whereArgs: [deviceInfo.id]);

    return result;
  }

  //Update Operation :Update a DeviceDBInfo object and save it to Database
  Future<int> updateDeviceDBInfoByName(DeviceDBInfo deviceInfo) async {
    var db = await this.database;
    var result = await db.update(deviceInfoTable, deviceInfo.toMap(),
        where: '$colDeviceName =?', whereArgs: [deviceInfo.name]);
    return result;
  }

//Delete Operation :Delete a DeviceDBInfo object from DataBase
  Future<int> deleteDeviceDBInfo(String deviceId) async {
    var db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $deviceInfoTable WHERE $colDeviceId =$deviceId');
    return result;
  }

  //Get number  of objects
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $deviceInfoTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //名称でデバイスを取得
  Future<DeviceDBInfo> getDeviceDBInfoByDeviceName(String deviceName) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT * from $deviceInfoTable WHERE $colDeviceName =$deviceName');
    if (x.length > 0) {
      Map<String, dynamic> deviceMap = x[0];
      DeviceDBInfo di = new DeviceDBInfo();
      di.fromMap(deviceMap);
      return di;
    }
    return null;
  }

  //IDでデバイスを取得
  Future<DeviceDBInfo> getDeviceDBInfoByDeviceId(String deviceId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT * from $deviceInfoTable WHERE $colDeviceId =$deviceId');
    if (x.length > 0) {
      Map<String, dynamic> deviceMap = x[0];
      DeviceDBInfo di = new DeviceDBInfo();
      di.fromMap(deviceMap);
      return di;
    }
    return null;
  }
}
