import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:marmo/views/device_read_view.dart';
import 'package:marmo/views/device_setting_view.dart';
import 'package:marmo/views/gpstracker_setting_view.dart';
import 'package:marmo/views/home_view.dart';
import 'package:marmo/views/login_view.dart';
import 'package:marmo/views/twice_view.dart';

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
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('en'), const Locale('ja')],
      routes: <String, WidgetBuilder>{
        'Login': (BuildContext context) => LoginView(),
        'Register': (BuildContext context) => TwiceCheckView(),
        'TwiceCheck': (BuildContext context) => TwiceCheckView(),
        'Home': (BuildContext context) => HomeView(),
        'Setting': (BuildContext context) => GpsTrackerSettingView(),
        'DeviceSetting': (BuildContext context) => DeviceSettingView(),
        'DeviceReading': (BuildContext context) => GpsTrackerReadingView(),
      },
    );
  }
}
