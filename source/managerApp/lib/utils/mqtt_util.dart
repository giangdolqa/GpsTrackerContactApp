// Mqtt通信ツール
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_tracker/beans/normal_info.dart';
import 'package:gps_tracker/beans/alarm_info.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:path_provider/path_provider.dart';

import 'event_util.dart';
import 'position_util.dart';
import 'shared_pre_util.dart';

final MqttUtil mqttUtil = MqttUtil();


class MqttUtil {
  // final client = MqttServerClient('test.mosquitto.org', ''); // 試験用サービス
  final client = MqttServerClient('ik1-407-35954.vs.sakura.ne.jp', ''); // 試験用サービス
  MqttUtil() {
    /// Set logging on if needed, defaults to off
    client.logging(on: false);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 20;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;
    // client.port = 8883; // 実装用
    client.port = 1883; // 試験用

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the broker
    /// rejects the subscribe request.
    client.onSubscribed = onSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the broker.
    client.pongCallback = pong;

    _initConn(); // 接続初期化(非同期
  }

  // 接続初期化(非同期
  void _initConn() async {
    final context = SecurityContext();
    context.setTrustedCertificates("assets/cert/cert.pem");

    String username = await spUtil.GetUsername();
    String password = await spUtil.GetPassword();

    username = "temporary";
    password = "password";

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final connMess = MqttConnectMessage()
        .withClientIdentifier("UniqueId")
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .authenticateAs(username, password)
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    exit(-1);
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
  }

  Future<String> getEncryptKey(String deviceName) async {
    String topic = deviceName +
        "/key/" +
        formatDate(DateTime.now(), [yyyy, mm, dd, HH, MM, ss]);
    client.subscribe(topic, MqttQos.exactlyOnce);
  }

  // 緯度経度がデバイスから配信
  getPosistionByDeviceName(String deviceName) {
    String topic = deviceName + "/#";
    client.subscribe(topic, MqttQos.exactlyOnce);

    client.updates.listen((dynamic c) {
      final MqttPublishMessage recMess = c[0].payload;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      NormalInfo pi;
      pi.jsonToNormalinfo(pt, null);
      eventBus.fire(pi);
    });
  }

  // 緊急通知取得
  getSurroundingUserInfo(String deviceName) {
    // final builder = MqttClientPayloadBuilder();
    // builder.addString('Hello from mqtt_client');
    double latitudeIn10Secs = globalTempPos.latitude * 60 * 60 / 10;
    double longitudeIn10Secs = globalTempPos.longitude * 60 * 60 / 10;

    // スマートフォンでは、自分の緯度経度から前後10秒の緯度経度の配信を購読できるようにする。
    // 	+/emg/10秒単位の緯度/10秒単位の経度
    // TopicList作成
    List<Map> latlngList = [];

    String latitude = latitudeIn10Secs.toString();
    String longitude = longitudeIn10Secs.toString();
    Map latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 	+/emg/10秒単位の緯度/10秒単位の経度-1
    latitude = latitudeIn10Secs.toString();
    longitude = (longitudeIn10Secs - 1).toString();
    latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 	+/emg/10秒単位の緯度/10秒単位の経度+1
    latitude = latitudeIn10Secs.toString();
    longitude = (longitudeIn10Secs + 1).toString();
    latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 	+/emg/10秒単位の緯度-1/10秒単位の経度
    latitude = latitudeIn10Secs.toString();
    longitude = (longitudeIn10Secs - 1).toString();
    latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 	+/emg/10秒単位の緯度-1/10秒単位の経度-1
    latitude = (latitudeIn10Secs - 1).toString();
    longitude = (longitudeIn10Secs - 1).toString();
    latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 	+/emg/10秒単位の緯度-1/10秒単位の経度+1
    latitude = (latitudeIn10Secs - 1).toString();
    longitude = (longitudeIn10Secs + 1).toString();
    latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 	+/emg/10秒単位の緯度+1/10秒単位の経度
    latitude = (latitudeIn10Secs + 1).toString();
    longitude = (longitudeIn10Secs).toString();
    latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 	+/emg/10秒単位の緯度+1/10秒単位の経度-1
    latitude = (latitudeIn10Secs + 1).toString();
    longitude = (longitudeIn10Secs - 1).toString();
    latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 	+/emg/10秒単位の緯度+1/10秒単位の経度+1
    latitude = (latitudeIn10Secs + 1).toString();
    longitude = (longitudeIn10Secs + 1).toString();
    latlngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    latlngList.add(latlngMap);

    // 購読実行
    latlngList.forEach((latlngMapItem) {
      String topic = deviceName +
          "/emg/" +
          latlngMapItem["latitude"] +
          "/" +
          latlngMapItem["longitude"];
      client.subscribe(topic, MqttQos.exactlyOnce);
    });

    client.updates.listen((dynamic c) {
      final MqttPublishMessage recMess = c[0].payload;
      String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      AlarmInfo ai = new AlarmInfo();
      var json = {
        "Lat": 38.67,
        "Lng": 12.66,
        "Sex": 1,
        "Age": 16
      };
      pt = json.toString();
      ai.jsonStrToAlarminfo(pt, null);
      eventBus.fire(ai);
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    });
  }
}
