// ホーム画面
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:toast/toast.dart';

import 'package:gps_tracker/components/my_popup_menu.dart' as mypopup;
import 'package:gps_tracker/utils/position_util.dart';

class HomeView extends StatefulWidget {
  HomeView();

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  // Global key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Timer myTimer;
  Timer occupiedCheckTimer;

  WidgetsBinding widgetsBinding;
  Color _statusbarColor = Colors.white;

  // user name
  String _userName = "";

  // phone number
  String _phoneNumber = "";

  @override
  void dispose() {
    // tabController.dispose();

    positionUtil.stopListening(context);
    if (myTimer != null) {
      myTimer.cancel();
    }
    if (occupiedCheckTimer != null) {
      occupiedCheckTimer.cancel();
    }
//    if (positionStream != null) {
//      positionStream.cancel();
//    }

    super.dispose();
  }

  //
  // void updateDrawerInfo() async {
  //   _userName = "";
  //   _phoneNumber = "";
  //   String tempName = await mapService.GetUserName();
  //   String tempPhn = await mapService.GetPhoneNumber();
  //   setState(() {
  //     _userName = tempName;
  //     _phoneNumber = tempPhn;
  //   });
  // }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            titlePadding: EdgeInsets.all(20),
            contentPadding: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: Text("確認"),
            content: Text("このアプリを閉じますか？"),
            actions: <Widget>[
              new RaisedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: new Text("Cancel"),
              ),
              new RaisedButton(
//                onPressed: () => Navigator.of(context).pop(true),
                onPressed: () {
                  exit(0);
                },
                child: new Text("OK"),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _onActionMenuSelect(String selectedVal) {
    switch (selectedVal) {
      case "home":
        positionUtil.getPermissions(context);
        positionUtil.startListen(context);
        Toast.show("ホーム", context);
        break;
      case "setting":
        Toast.show("設定", context);
        break;
      case "read":
        Toast.show("読み込み", context);
        break;
      case "contact":
        Toast.show("接触確認", context);
        break;
      default:
        // do nothing
        Toast.show("Unexpected action", context);
        break;
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: () async {
      //   return false;
      // },
      onWillPop: _onWillPop,
      child: Container(
        color: _statusbarColor,
        child: SafeArea(
//          maintainBottomViewPadding: true,
          child: new Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
                Container(
                    height: 36,
                    color: Colors.red,
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Marquee(
                      text: '近くで10歳の男の子が助けを求めています、早く助けに行け！！',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blankSpace: 20.0,
                      velocity: 50.0,
                      pauseAfterRound: Duration(seconds: 5),
                      startPadding: 10.0,
                      accelerationDuration: Duration(seconds: 2),
                      accelerationCurve: Curves.easeIn,
                      decelerationDuration: Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    )),
              ],
            ),
            floatingActionButton: Padding(
              // アクションボタン
              child: Container(
                decoration: new BoxDecoration(
                  color: Color(0xFFC4C4C4),
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: mypopup.PopupMenuButton(
                  icon: Icon(
                    Icons.list,
                    color: Colors.white,
                    size: 32,
                  ),
                  offset: Offset(0, 80),
                  itemBuilder: (_) => <mypopup.PopupMenuItem<String>>[
                    new mypopup.PopupMenuItem<String>(
                      child: Container(
                        height: double.infinity,
                        width: 120,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 5, top: 5),
                              child: Icon(
                                Icons.home_filled,
                                size: 30,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 5, top: 5),
                                child: Text(
                                  "ホーム",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                // alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      value: "home",
                    ),
                    new mypopup.PopupMenuItem<String>(
                      child: Container(
                        height: double.infinity,
                        width: 120,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 5, top: 5),
                              child: Icon(
                                Icons.settings,
                                size: 30,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 5, top: 5),
                                child: Text(
                                  "設定",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                // alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      color: Color(0x55c4c4c4),
                      value: "setting",
                    ),
                    new mypopup.PopupMenuItem<String>(
                      child: Container(
                        height: double.infinity,
                        width: 120,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 5, top: 5),
                              child: Icon(
                                Icons.autorenew,
                                size: 30,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 5, top: 5),
                                child: Text(
                                  "読込",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                // alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      value: "read",
                    ),
                    new mypopup.PopupMenuItem<String>(
                      child: Container(
                        height: double.infinity,
                        width: 120,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 5, top: 5),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 30,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 5, top: 5),
                                child: Text(
                                  "接触確認",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                // alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      color: Color(0x55c4c4c4),
                      value: "contact",
                    ),
                  ],
                  onSelected: _onActionMenuSelect,
                ),
              ),
              padding: EdgeInsets.only(top: 10),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniStartTop,
          ),
        ),
      ),
    );
  }
}