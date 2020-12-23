import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
//import 'package:location/location.dart' as lc;

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
    const timerLength = const Duration(seconds: 5);
    var callback = (timer) => {_timeOut()};
    posTimer = Timer.periodic(timerLength, callback);

    // geolocator stream
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 3, forceAndroidLocationManager: true, timeInterval: 2000);
    positionStream = geolocator.getPositionStream(locationOptions).listen((Position position) {
      if (position != null) {
        if (globalTempPos != null){
          double xVal = position.latitude - globalTempPos.latitude;
          double yVal = position.longitude - globalTempPos.longitude;
          globalDirection = atan2(xVal, yVal) / pi * 180.00;
        }
        globalTempPos = position;
      }
    });

//    // Location Stream
//    geolocator.onLocationChanged().listen((lc.LocationData position) {
//      // Use current location
//      if (position != null) {
//        print(position.toString());
//        if (globalTempPos != null) {
//          double xVal = position.latitude - globalTempPos.latitude;
//          double yVal = position.longitude - globalTempPos.longitude;
//          globalDirection = atan2(xVal, yVal) / pi * 180.00;
//        }
//        globalTempPos = Position(
//          latitude: position.latitude,
//          longitude: position.longitude,
//          speed: position.speed,
//          heading: position.heading,
//        );
//      }
//    });
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
      Position rsltPos = await geolocator.getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      if (rsltPos == null) {
        print("GetCurrentPos Failed: getCurrentPosition");
        rsltPos = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//          rsltPos = await geolocator.getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
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

//  //  With Location
//  void CheckLocationPermission() async {
//    var isPerms = await geolocator.hasPermission();
//    if (isPerms != lc.PermissionStatus.GRANTED) {
//      geolocator.requestPermission();
////      print("-----------------------------------------------------GetCurrentPos requestPermission ");
//    } else {
////      print("-----------------------------------------------------GetCurrentPos secceeded requestPermission ");
//    }
//    var isService = await geolocator.serviceEnabled();
//    if (isService != true) {
//      geolocator.requestService();
////      print("-----------------------------------------------------GetCurrentPos requestService ");
//    } else {
////      print("-----------------------------------------------------GetCurrentPos secceeded requestService ");
//    }
//  }
//
//  Future<Position> GetCurrentPos() async {
//    if (globalTempPos != null) {
//      return globalTempPos;
//    }
//    try {
////      Position rsltPos = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//      lc.LocationData rsltLD = await geolocator.getLocation();
//      if (rsltLD != null) {
//        Position rsltPos = Position(longitude: rsltLD.longitude, latitude: rsltLD.latitude, speed: rsltLD.speed, heading: rsltLD.heading);
//        globalTempPos = rsltPos;
//        return rsltPos;
//      }
//    } catch (e) {
//      print("GetCurrentPos Failed: Exception " + e.toString());
//    }
//    return null;
//  }
}
