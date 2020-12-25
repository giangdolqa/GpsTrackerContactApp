//import 'package:animated_splash/animated_splash.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gps_tracker/views/home_view.dart';

void main() => runApp(
    TrackerApp());

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
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'GPSTracker',
      debugShowCheckedModeBanner: true,
      // home: LoginView(),
      home: HomeView(),
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        // 'Login': (BuildContext context) => LoginView(),  // ログインはここに追加
        'Home': (BuildContext context) => HomeView(),
      },
    );
  }
}
