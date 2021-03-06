// バックグランド位置通知
import 'dart:async';
import 'dart:math';

import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

PositionUtil positionUtil = new PositionUtil();
Position globalTempPos;
bool PosFlag = false; //  Already dealing with get position
Timer posTimer;
double globalDirection;

//var geolocator = Geolocator();
var geolocator = Geolocator()..forceAndroidLocationManager = true;
//lc.Location geolocator = new lc.Location();
StreamSubscription<Position> positionStream;

class PositionUtil {
  static const MethodChannel _channel =
      const MethodChannel('almoullim.com/background_location');

  PositionUtil() {
    const timerLength = const Duration(seconds: 60); // 分毎に位置通知
    var callback = (timer) => {_timeOut()};
    posTimer = Timer.periodic(timerLength, callback);

    // geolocator stream
    var locationOptions = LocationOptions(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
        forceAndroidLocationManager: true,
        timeInterval: 2000);
    positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      if (position != null) {
        if (globalTempPos != null) {
          double xVal = position.latitude - globalTempPos.latitude;
          double yVal = position.longitude - globalTempPos.longitude;
          globalDirection = atan2(xVal, yVal) / pi * 180.00;
        }
        globalTempPos = position;
      }
    });
  }

  // 位置通知サービス開始
  startListen(BuildContext context) async {
    // mqttUtil.client.connect("username", "password");
    await BackgroundLocation.stopLocationService();
    await BackgroundLocation.setAndroidNotification(
      title: "Background service is running",
      message: "Background location in progress",
      icon: "@mipmap/ic_launcher",
    );
    await BackgroundLocation.setAndroidConfiguration(interval: 1000);
    await BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      String locString = "latitude: " +
          location.latitude.toString() +
          "   longitude: " +
          location.longitude.toString() +
          "   accuracy: " +
          location.accuracy.toString() +
          "   speed: " +
          location.speed.toString();
      // Toast.show(locString , context);
      print(locString);
      globalTempPos =
          Position(latitude: location.longitude, longitude: location.longitude);
    });
  }

  // 位置通知サービス停止
  stopListening(BuildContext context) async {
    BackgroundLocation.stopLocationService();
  }

  // 権限要求
  void getPermissions(BuildContext context) {
    BackgroundLocation.checkPermissions().then((status) {
      if (status == PermissionStatus.granted) {
        Toast.show(status.toString(), context);
      } else {
        BackgroundLocation.getPermissions(
          onGranted: () {
            // Start location service here or do something else
            Toast.show("権限付与成功しました。", context);
          },
          onDenied: () {
            Toast.show("権限取得しました。", context);
          },
        );
      }
    });
  }

  getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      print("This is current Location" + location.longitude.toString());
    });
  }

  void _timeOut() async {
    PosFlag = false;
  }

  void dispose() {
    posTimer.cancel();
    positionStream.cancel();
  }

  // With Geolocator
  void CheckLocationPermission() async {
    var isPerms = await geolocator.checkGeolocationPermissionStatus();
    bool isService = await geolocator.isLocationServiceEnabled();
    if (isService) {
      print(isPerms.toString() + "Loaction Service enabled");
    } else {
      print(isPerms.toString() + "Loaction Service disabled");
    }
  }

  Future<Position> GetCurrentPos() async {
    if (globalTempPos != null) {
      return globalTempPos;
    } else {
      Position rsltPos = await geolocator.getLastKnownPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (rsltPos == null) {
        print("GetCurrentPos Failed: getCurrentPosition");
        rsltPos = await geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (rsltPos == null) {
          print("GetCurrentPos Failed: getLastKnownPosition");
        }
      }
      if (rsltPos != null) {
        globalTempPos = rsltPos;
        return rsltPos;
      }
    }
    return null;
  }
}
