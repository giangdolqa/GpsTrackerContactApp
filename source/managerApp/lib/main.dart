//import 'package:animated_splash/animated_splash.dart';

import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_tracker/utils/mqtt_util.dart';

import 'package:gps_tracker/views/login_view.dart';
import 'package:gps_tracker/views/register_view.dart';
import 'package:gps_tracker/views/home_view.dart';
import 'package:gps_tracker/views/gpstracker_setting_view.dart';
import 'package:gps_tracker/views/device_setting_view.dart';
import 'package:workmanager/workmanager.dart';

// 常駐位置更新
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print("Native called background task: $inputData"); //simpleTask will be emitted here.
    mqttUtil.getSurroundingUserInfo();
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 常駐機能を登録
  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  Workmanager.registerPeriodicTask("2", "PeriodicTask", tag: "daemon");

  runApp(TrackerApp());
}

class TrackerApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  TrackerAppState createState() => TrackerAppState();
}

class TrackerAppState extends State<TrackerApp> {
  WidgetsBinding widgetsBinding;

  //
  // // AuthCheck
  // LoginService loginService = new LoginService();
//  bool authCheckRslt = false;

//  AuthCheck() async {
//    int authRslt = await loginService.StartupAuthCheck();
//
//    if (authRslt == 0) {
//      //print("Auth Checking...true");
//      return true;
//    } else {
//      //print("Auth Checking...false");
//      return false;
//    }
//  }
//
////
//  @override
//  void initState() {
//    super.initState();
//    AuthCheck().then((result) {
//      // If we need to rebuild the widget with the resulting data,
//      // make sure to use `setState`
//      authCheckRslt = result;
//    });
//    widgetsBinding = WidgetsBinding.instance;
//    widgetsBinding.addPostFrameCallback((callback) async {
//      //print("Buidling done...");
//    });
//  }
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    BackgroundLocation.stopLocationService();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'GPSTracker',
      debugShowCheckedModeBanner: true,
      home: LoginView(),
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        'Login': (BuildContext context) => LoginView(),
        'Register': (BuildContext context) =>
            RegisterView.nextViewPath("TwiceCheck"), // 2段階認証に値渡し
        //'TwiceCheck': (BuildContext context) => TwiceCheckView(),  // 2段階認証
        'Home': (BuildContext context) => HomeView(),
        'Setting': (BuildContext context) => GpsTrackerSettingView(),
        'DeviceSetting': (BuildContext context) => DeviceSettingView(),
      },
    );
  }
}
