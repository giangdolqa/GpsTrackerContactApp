// ホーム画面
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
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
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/beans/normal_info.dart';
import 'package:marmo/beans/alarm_info.dart';
import 'package:marmo/utils/db_util.dart';
import 'package:marmo/utils/event_util.dart';
import 'package:marmo/utils/nuid_util.dart';
import 'package:marmo/utils/sound_util.dart';
import 'package:marquee/marquee.dart';
import 'package:toast/toast.dart';

import 'package:marmo/components/my_popup_menu.dart' as mypopup;
import 'package:marmo/utils/position_util.dart';
import 'package:marmo/utils/mqtt_util.dart';
import 'package:workmanager/workmanager.dart';

class HomeView extends StatefulWidget {
  HomeView();

  @override
  HomeViewState createState() => HomeViewState();
}

// 常駐位置更新
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print(
        "WorkManager Executed !!  Native called background task: $inputData"); //simpleTask will be emitted here.
    MqttUtil tmpMqttUtil = new MqttUtil();
    tmpMqttUtil.getAllDeviceAlarmInfo();
    print(
        "WorkManager Done !!  Native called background task: $inputData"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  // Global key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController googleMapController;

  Completer<GoogleMapController> _controller = Completer();

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
    // positionUtil.getPermissions(context);
    // positionUtil.startListen(context);
    // 常駐機能を登録
    Workmanager.initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode:
            true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );
    Workmanager.registerPeriodicTask("2", "PeriodicTask", tag: "daemon");

    // 緊急通知処理登録
    eventBus.on<AlarmInfo>().listen((event) {
      if (mounted) {
        // List<Position> alarmList = [];
        // alarmList.add(event.position);
        SoundUtil.playAssetSound(null);
        _addAlarmCustomMarker(event);
      }
    });
    // 一般通知処理登録
    eventBus.on<NormalInfo>().listen((event) {
      if (mounted) {
        List<NormalInfo> normalInfoList = [];
        normalInfoList.add(event);
        _addNormalMarkers(event);
      }
    });
    //
    // mqttUtil.connect();
    mqttUtil.getAllDeviceAlarmInfo();
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
        CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(
            LatLng(currentLocation.latitude, currentLocation.longitude), 22);
        googleMapController.moveCamera(cameraUpdate);
        // _onMarkerTapped(markerId);
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

  // 緊急メッセージ＆マーカー追加
  void _addAlarmCustomMarker(AlarmInfo ai) async {
    var bubbleWidth = 0;
    var bubbleHeight = 0;

    MarkerId markerId = new MarkerId(nuid.next());

    // avatar
    final bytes = await rootBundle.load('assets/icon/help.png');
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;
    bubbleWidth += image.width;
    bubbleHeight += image.height;

    // text
    final span = TextSpan(
        style: TextStyle(
          color: Colors.white,
          fontSize: 60,
          fontWeight: FontWeight.bold,
        ),
        text: "助けて");
    final textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr)
      ..layout();
    const textMarginLeft = 4.0;

    final clipWidth = image.width.toDouble();
    final clipHeight = image.height.toDouble();

    // drawing
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(
        pictureRecorder, Rect.fromLTWH(0, 0, clipWidth, clipHeight))
      ..drawImage(
          image, const Offset(0, 0), Paint()..blendMode = BlendMode.dstOver);
    textPainter.paint(canvas, Offset(65, textPainter.height / 2.0 + 10));
    final pic = pictureRecorder.endRecording();

    // rasterizing
    final markerImage =
        await pic.toImage(clipWidth.toInt(), clipHeight.toInt());
    final byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData.buffer.asUint8List();

    LatLng position = LatLng(ai.position.latitude, ai.position.longitude);

    final tmpMarker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(uint8List),
        anchor: Offset(0.5, 1),
        onTap: () {
          CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(
              LatLng(ai.position.latitude, ai.position.longitude), 14);
          googleMapController.moveCamera(cameraUpdate);
          // _onMarkerTapped(markerId);
        },
        position: position);

    markers[markerId] = tmpMarker;

    // メッセージ更新
    String alarmMessage = _makeAlarmMessage(ai);
    messageMap[markerId] = alarmMessage;

    setState(() {
      markersSet = markers.values.toSet();
      alarmText = _concactAlarmMessage(messageMap.values.toList());
    });
  }

  String _makeAlarmMessage(AlarmInfo ai) {
    String rsltString = "";
    String Age = ai.Age.toString() + "歳の";
    String gender = "";

    if (ai.Age > 17) {
      switch (ai.Sex) {
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
    } else {
      switch (ai.Sex) {
        case 0:
          gender = "子";
          break;
        case 1:
          gender = "男の子";
          break;
        case 2:
          gender = "女の子";
          break;
        default:
          gender = "子";
          break;
      }
    }

    rsltString = "近くで" + Age + gender + "が助けを求めています。";
    return rsltString;
  }

  // 緊急情報ロール表示文字列作成
  String _concactAlarmMessage(List<String> messageList) {
    String rsltString = "";
    messageList.forEach((alarmMessage) {
      if (rsltString.isEmpty) {
        rsltString = alarmMessage;
      } else {
        rsltString = rsltString + "      " + alarmMessage;
      }
    });
    return rsltString;
  }

  // 緊急メッセージ＆マーカー削除
  void deleteAlarm(String alarmMessage, Position alarmPosition) async {}

  // 押下した緊急マーカーを削除
  _onMarkerTapped(MarkerId markerId) {
    markers.remove(markerId);
    messageMap.remove(markerId);
    setState(() {
      markersSet = markers.values.toSet();
      alarmText = _concactAlarmMessage(messageMap.values.toList());
    });
  }

  //
  // // 緊急マーカ作成＆表示
  // _addAlarmMarkers(List<Position> positions) async {
  //   // alarmMarkerIds.clear();
  //   BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(size: Size(20, 20)), 'assets/icon/help.png');
  //   Position currentLocation = await geolocator.getCurrentPosition();
  //   positions.forEach((position) {
  //     MarkerId markerId = new MarkerId("a" + alarmMarkerIds.length.toString());
  //     Marker tmpMarker = Marker(
  //       markerId: markerId,
  //       // icon: Icon(Icons.location_pin),
  //       icon: markerIcon,
  //       anchor: Offset(0.5, 1),
  //       onTap: () {
  //         CameraUpdate cameraUpdate = CameraUpdate.newLatLng(
  //             LatLng(currentLocation.latitude, currentLocation.longitude));
  //         controller.moveCamera(cameraUpdate);
  //         controller.zoomIn(animate: true);
  //
  //         _onMarkerTapped(markerId);
  //       },
  //       position: LatLng(position.latitude, position.longitude),
  //     );
  //     alarmMarkerIds.add(markerId);
  //     markers[markerId] = tmpMarker;
  //     this.setState(() {
  //       markersSet = markers.values;
  //     });
  //   });
  // }

  // 通常マーカ作成＆表示
  _addNormalMarkers(NormalInfo position) async {
    // normalMarkerIds.clear();

    // BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(size: Size(5, 5)), 'assets/icon/position.png');
    // BitmapDescriptor markerIcon = await BitmapDescriptor.defaultMarkerWithHue(
    //     colorsHue[colorIndex]);
    List colors = [
      Colors.yellow,
      Colors.red,
      Colors.blue,
      Colors.blue,
      Colors.cyan,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    Random random = new Random();
    int colorIndex = random.nextInt(colors.length - 1);

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()..color = colors[colorIndex];
    double radius = 20;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    final image = await pictureRecorder.endRecording().toImage(
          radius.toInt() * 2,
          radius.toInt() * 2,
        );
    final data = await image.toByteData(format: ImageByteFormat.png);
    BitmapDescriptor markerIcon =
        await BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    Position currentLocation = await geolocator.getCurrentPosition();
    // positions.forEach((position) {
    var next = nuid.next();
    MarkerId markerId = new MarkerId(next);
    CircleId circleId = new CircleId(next);
    Marker tmpMarker = Marker(
      markerId: markerId,
      icon: markerIcon,
      anchor: Offset(0.5, 0.5),
      position: LatLng(position.latitude, position.longitude),
      onTap: () {
        _createRoute(
            currentLocation,
            Position(
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
      fillColor: colors[colorIndex].withOpacity(0.3),
      strokeWidth: 0,
    );
    circles.add(tempCircle);
    this.setState(() {
      markersSet = markers.values.toSet();
      circleSet = circles.toSet();
    });
    // });
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
        // // ホーム画面へ遷移
        // AlarmInfo ai = new AlarmInfo();
        // ai.position = Position(latitude: 38.94870994, longitude: 121.59347778);
        // ai.Age = 16;
        // ai.Sex = 1;
        //
        // _addAlarmCustomMarker(ai);
        //
        // List<NormalInfo> niList = [];
        // NormalInfo ni = new NormalInfo();
        // ni.name = "テスト太郎";
        // ni.description = "aodi/sdfs %dsdofji";
        // ni.latitude = 38.94872994;
        // ni.longitude = 121.59357778;
        // _addNormalMarkers(ni);
        //
        // NormalInfo ni1 = new NormalInfo();
        // ni1.name = "テスト次郎";
        // ni1.description = "213/sdfs %dsdofji";
        // ni1.latitude = 38.95872994;
        // ni1.longitude = 121.55357778;
        // _addNormalMarkers(ni1);
        //
        // AlarmInfo ai2 = new AlarmInfo();
        // var json = {
        //   "Lat": 38.67,
        //   "Lng": 12.66,
        //   "Sex": 1,
        //   "Age": 16
        // };
        // String jsonStr = jsonEncode(json);
        // ai.jsonStrToAlarminfo(jsonStr, null);
        break;
      case "setting":
        Navigator.of(context).pushNamed('Setting');
        // 設定画面へ遷移
        break;
      case "read":
        // 読み込み処理
        Navigator.of(context).pushNamed("DeviceReading");
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
                alarmText.isNotEmpty
                    ? Container(
                        height: 36,
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
                      )
                    : Container(),
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
                      itemBuilder: (_) => <mypopup.PopupMenuItem<String>>[
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
