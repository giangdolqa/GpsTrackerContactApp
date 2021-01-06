// ホーム画面
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_volume_slider/flutter_volume_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_controller/google_maps_controller.dart';
import 'package:gps_tracker/beans/normal_info.dart';
import 'package:gps_tracker/beans/alarm_info.dart';
import 'package:gps_tracker/utils/event_util.dart';
import 'package:gps_tracker/utils/nuid_util.dart';
import 'package:marquee/marquee.dart';
import 'package:toast/toast.dart';

import 'package:gps_tracker/components/my_popup_menu.dart' as mypopup;
import 'package:gps_tracker/utils/position_util.dart';
import 'package:gps_tracker/utils/mqtt_util.dart';

class HomeView extends StatefulWidget {
  HomeView();

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  // Global key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController googleMapController;

  Completer<GoogleMapController> _controller = Completer();
  var controller = GoogleMapsController();

  static final CameraPosition _kTokyo =
  CameraPosition(target: LatLng(35.69, 139.69), zoom: 14);

  Timer myTimer;
  Timer occupiedCheckTimer;

  WidgetsBinding widgetsBinding;
  Color _statusbarColor = Colors.white;

  String alarmText = '';

  // 画面初期化
  @override
  void initState() {
    super.initState();
    // 位置情報取得開始
    positionUtil.getPermissions(context);
    positionUtil.startListen(context);

    // 緊急通知処理登録
    eventBus.on<AlarmInfo>().listen((event) {
      if (mounted) {
        List<Position> alarmList = [];
        alarmList.add(event.position);
        _addAlarmMarkers(alarmList);
      }
    });
    // 一般通知処理登録
    eventBus.on<NormalInfo>().listen((event) {
      if (mounted) {
        List<NormalInfo> normalInfoList = [];
        normalInfoList.add(event);
        _addNormalMarkers(normalInfoList);
      }
    });
  }

  // 画面破棄
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

  // ルート表示用データ
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};
  List<LatLng> markerCoordinates = [];
  List<Circle> circles = [];
  List<MarkerId> alarmMarkerIds = [];
  List<MarkerId> normalMarkerIds = [];
  Set<Marker> markersSet = Set();
  Set<Circle> circleSet = Set();
  Map<MarkerId, String> messageMap = {};
  bool sliderVisible = false;

  // 緊急メッセージ＆マーカー追加
  void addAlarm(AlarmInfo ai) async {
    // マーカー更新
    MarkerId markerId = new MarkerId(nuid.next());
    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(20, 20)), 'assets/icon/help.png');
    Position currentLocation = await geolocator.getCurrentPosition();
    Marker tmpMarker = Marker(
      markerId: markerId,
      // icon: Icon(Icons.location_pin),
      icon: markerIcon,
      anchor: Offset(0.5, 1),
      onTap: () {
        CameraUpdate cameraUpdate = CameraUpdate.newLatLng(LatLng(
            currentLocation.latitude, currentLocation.longitude));
        controller.moveCamera(cameraUpdate);
        controller.zoomIn(animate: true);
        _onMarkerTapped(markerId);
      },
      position: LatLng(ai.position.latitude, ai.position.longitude),
    );
    markers[markerId] = tmpMarker;

    // メッセージ更新
    String alarmMessage = _makeAlarmMessage(ai);
    messageMap[markerId] = alarmMessage;


    setState(() {
      markersSet = markers.values;
      alarmText = _concactAlarmMessage(messageMap.values);
    });
  }

  String _makeAlarmMessage(AlarmInfo ai) {
    String rsltString = "";
    String age = ai.age.toString() + "歳の";
    String gender = "";
    switch (ai.sex) {
      case 0:
        gender = "人";
        break;
      case 1:
        gender = "男性";
        break;
      case 2:
        gender = "女性";
        break;
      default:
        gender = "人";
        break;
    }
    rsltString = "近くて"
    + gender;
    return rsltString;
  }

  String _concactAlarmMessage(List<String> messageList) {
    String rsltString = "";
    messageList.forEach((alarmMessage) {
      if (rsltString.isEmpty) {
        rsltString = alarmMessage;
      }
      else {
        rsltString = rsltString + "      " + alarmMessage;
      }
    });
    return rsltString;
  }


  // 緊急メッセージ＆マーカー削除
  void deleteAlarm(String alarmMessage, Position alarmPosition) async {

  }


  // 押下した緊急マーカーを削除
  _onMarkerTapped(MarkerId markerId) {
    markers.remove(markerId);
    messageMap.remove(markerId);
  }

  // 緊急マーカ作成＆表示
  _addAlarmMarkers(List<Position> positions) async {
    // alarmMarkerIds.clear();
    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(20, 20)), 'assets/icon/help.png');
    Position currentLocation = await geolocator.getCurrentPosition();
    positions.forEach((position) {
      MarkerId markerId = new MarkerId("a" + alarmMarkerIds.length.toString());
      Marker tmpMarker = Marker(
        markerId: markerId,
        // icon: Icon(Icons.location_pin),
        icon: markerIcon,
        anchor: Offset(0.5, 1),
        onTap: () {
          CameraUpdate cameraUpdate = CameraUpdate.newLatLng(LatLng(
              currentLocation.latitude, currentLocation.longitude));
          controller.moveCamera(cameraUpdate);
          controller.zoomIn(animate: true);

          _onMarkerTapped(markerId);
        },
        position: LatLng(position.latitude, position.longitude),
      );
      alarmMarkerIds.add(markerId);
      markers[markerId] = tmpMarker;
      this.setState(() {
        markersSet = markers.values;
      });
    });
  }

  // 通常マーカ作成＆表示
  _addNormalMarkers(List<NormalInfo> positions) async {
    // normalMarkerIds.clear();
    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(5, 5)), 'assets/icon/position.png');
    Position currentLocation = await geolocator.getCurrentPosition();
    positions.forEach((position) {
      MarkerId markerId = new MarkerId("n" + normalMarkerIds.length.toString());
      CircleId circleId = new CircleId("p" + normalMarkerIds.length.toString());
      Marker tmpMarker = Marker(
        markerId: markerId,
        icon: markerIcon,
        anchor: Offset(0.5, 0.5),
        position: LatLng(position.latitude, position.longitude),
        onTap: () {
          _createRoute(currentLocation, Position(
              latitude: position.latitude, longitude: position.longitude));
        },
        infoWindow: InfoWindow(
          title: position.name,
          snippet: position.description,
        ),
      );
      normalMarkerIds.add(markerId);
      markers[markerId] = tmpMarker;
      Circle tempCircle = Circle(
        circleId: circleId,
        center: LatLng(position.latitude, position.longitude),
        radius: 2.5,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeWidth: 0,
      );
      circles.add(tempCircle);
      this.setState(() {
        markersSet = markers.values;
        circleSet = circles.toSet();
        });
    });
  }

  // マーカを全部クリア
  _clearMarker() {
    this.setState(() {
      markers.clear();
      normalMarkerIds.clear();
      alarmMarkerIds.clear();
      circleSet.clear();
      markersSet.clear();
    });
  }

  // ルート作成＆表示
  _createRoute(Position start, Position destination) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();
    // ルートを更新
    this.setState(() {
      polylines.clear();
      polylineCoordinates.clear();
    });

    // ルートの点列を取得
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAjkgfUAoTE7Lj-8I7UeaSK7caRoocDqTs", // Google Maps API Key
      // "AIzaSyDpnYHpHvnRmswAnPaTfR4doezXWhT6UiA", // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.walking,
    );

    // 点を線に追加
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // ID作成
    PolylineId id = PolylineId('poly');

    // 線を定義
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // ルートを更新
    this.setState(() {
      polylines[id] = polyline;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) =>
      new AlertDialog(
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
      // ホーム画面へ遷移
        break;
      case "setting":
        Navigator.of(context).pushNamed('Setting');
        // 設定画面へ遷移
        break;
      case "read":
      // 読み込み処理
        break;
      case "contact":
      // 接触確認処理
        break;
      default:
      // do nothing
        break;
    }
    return;
  }

  _showVolumeSlider() {
    setState(() {
      normalMarkerIds.forEach((markerId) {
        googleMapController.showMarkerInfoWindow(markerId);
      });
      sliderVisible = !sliderVisible;
    });
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
                    polylines: Set<Polyline>.of(polylines.values),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    markers: markersSet,
                    circles: circleSet,
                    initialCameraPosition: _kTokyo,
                    onMapCreated: (GoogleMapController controller) async {
                      _controller.complete(controller);
                      googleMapController = await _controller.future;
                      Position currentLocation =
                      await geolocator.getCurrentPosition();
                      CameraUpdate cameraUpdate = CameraUpdate.newLatLng(LatLng(
                          currentLocation.latitude, currentLocation.longitude));
                      googleMapController.moveCamera(cameraUpdate);
                    },
                  ),
                ),
                Container(
                  height: alarmText.isNotEmpty ? 36 : 0,
                  color: Colors.red,
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Marquee(
                    text: alarmText,
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
                  ),
                ),
              ],
            ),
            floatingActionButton: Padding(
              child: Row(
                children: [
                  // アクションボタン
                  Container(
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
                      itemBuilder: (_) =>
                      <mypopup.PopupMenuItem<String>>[
                        new mypopup.PopupMenuItem<String>(
                          child: Container(
                            height: double.infinity,
                            width: 120,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    padding: EdgeInsets.only(left: 5, top: 5),
                                    child: Image.asset(
                                      "assets/icon/home.png",
                                      width: 30,
                                      height: 30,
                                    )),
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
                                  child: Image.asset(
                                    "assets/icon/check.png",
                                    width: 30,
                                    height: 30,
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
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        sliderVisible
                            ? Container(
                          height: 50,
                          child: Center(
                            child: FlutterVolumeSlider(
                              display: Display.HORIZONTAL,
                              sliderActiveColor: Colors.blue,
                              sliderInActiveColor: Colors.grey,
                            ),
                          ),
                        )
                            : Container(
                          height: 50,
                          color: Colors.blue,
                        ),
                        Container(
                          // color: Colors.amber,
                          padding: EdgeInsets.only(
                            right: 20,
                            top: 3,
                          ),
                          height: 50,
                          child: IconButton(
                            icon: Icon(
                              Icons.volume_up,
                              color: Colors.blue,
                              size: 26,
                            ),
                            onPressed: _showVolumeSlider,
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                  ),
                ],
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
