// バックグランド位置通知
import 'dart:async';
import 'dart:math';

import 'package:background_location/background_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:popup_menu/popup_menu.dart';

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

   _initLocation() async {
    await BackgroundLocation.setAndroidNotification(
      title: "Background service is running",
      message: "Background location in progress",
      icon: "@mipmap/ic_launcher",
    );
    await BackgroundLocation.setAndroidConfiguration();
    await BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      // setState(() {
      //   this.latitude = location.latitude.toString();
      //   this.longitude = location.longitude.toString();
      //   this.accuracy = location.accuracy.toString();
      //   this.altitude = location.altitude.toString();
      //   this.bearing = location.bearing.toString();
      //   this.speed = location.speed.toString();
      //   this.time = DateTime.fromMillisecondsSinceEpoch(
      //       location.time.toInt())
      //       .toString();
      // });
      // print("""\n
      //                   Latitude:  $latitude
      //                   Longitude: $longitude
      //                   Altitude: $altitude
      //                   Accuracy: $accuracy
      //                   Bearing:  $bearing
      //                   Speed: $speed
      //                   Time: $time
      //                 """);
    });
  }


  getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      print("This is current Location" + location.longitude.toString());
    });
  }


  void _timeOut() async {
    PosFlag = false;
//    print("Position Update Endabled.........................");
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
