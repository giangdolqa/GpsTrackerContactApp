//　ローカルDB
import 'package:gps_tracker/beans/device_dbInfo.dart';
import 'package:gps_tracker/beans/device_info.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DbUtil {
  static DbUtil dbUtil; //Singleton DbUtil
  static Database _database; //Singleton Database

//Database table name along with column name
  String marmoTable = 'marmo_table';
  String colId = 'id';  //　DeviceId
  String colDeviceName = 'name';  // デバイス名
  String colDeviceKey = 'key';  // 暗号キー
  String colState = 'state';  // 設定済みステート 0:未 1:済み
  String colUserName = 'username';  // ユーザー名称

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
    String path = join(directory.path, 'marmo.db');

    var marmoDatabase = openDatabase(path, version: 1, onCreate: _createDb);
    return marmoDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $marmoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colDeviceName TEXT, '
            '$colDeviceKey TEXT, $colState INTEGER, $colUserName TEXT)');
  }

//Fetch Operation :Get all object from database
  Future<List<Map<String, dynamic>>> getDeviceDBInfoMapList() async {
    Database db = await this.database;

//var result= db.rawQuery('SELECT * FROM $marmoTable order by $colState ASC');
    var result = db.query(marmoTable, orderBy: '$colState ASC');
    return result;
  }

//Insert Operation :Insert a DeviceDBInfoboject to database

  Future<int> insertDeviceDBInfo(DeviceDBInfo di) async {
    Database db = await this.database;
    var result = await db.insert(marmoTable, di.toMap());
    return result;
  }

//Update Operation :Update a DeviceDBInfo object and save it to Database
  Future<int> updateDeviceDBInfo(DeviceDBInfo marmo) async {
    var db = await this.database;
    var result = await db.update(marmoTable, marmo.toMap(),
        where: '$colId =?', whereArgs: [marmo.id]);

    return result;
  }

//Delete Operation :Delete a DeviceDBInfo object from DataBase
  Future<int> deleteDeviceDBInfo(int id) async {
    var db = await this.database;
    var result = await db.rawDelete('DELETE FROM $marmoTable WHERE $colId =$id');
    return result;
  }
  //Get number  of objects

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x=await db.rawQuery('SELECT COUNT (*) from $marmoTable');
    int result =Sqflite.firstIntValue(x);
    return result;
  }
}