import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marmo/views/device_read_view.dart';
import 'package:marmo/views/device_setting_view.dart';
import 'package:marmo/views/gpstracker_setting_view.dart';
import 'package:marmo/views/home_view.dart';
import 'package:marmo/views/login_view.dart';
import 'package:marmo/views/register_view.dart';

void main() {
  runApp(TrackerApp());
}

class TrackerApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  TrackerAppState createState() => TrackerAppState();
}

class TrackerAppState extends State<TrackerApp> {
  WidgetsBinding widgetsBinding;

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
      title: 'Marmo',
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
        'DeviceReading': (BuildContext context) => GpsTrackerReadingView(),
      },
    );
  }
}
