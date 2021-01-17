// Mqtt通信ツール
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/beans/key_info.dart';
import 'package:marmo/beans/normal_info.dart';
import 'package:marmo/beans/alarm_info.dart';
import 'package:marmo/utils/sound_util.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'db_util.dart';
import 'event_util.dart';
import 'position_util.dart';
import 'shared_pre_util.dart';

final MqttUtil mqttUtil = MqttUtil();

class MqttUtil {
  // final client = MqttServerClient('test.mosquitto.org', ''); // 試験用サービス
  final client = MqttServerClient('broker.emqx.io', ''); // 試験用サービス
  // final client =  MqttServerClient('ik1-407-35954.vs.sakura.ne.jp', '');
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
    // client.port = 8883; // 試験用
    // client.port = 8083 ; // 試験用
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
  }

  // 接続初期化(非同期
  void _initConn() async {
    final context = SecurityContext.defaultContext;
    // context.setTrustedCertificates(path.join('assets', 'cert', 'cert.pem'));
    // context.setTrustedCertificates("/assets/cert/cert.pem");
    ByteData data = await rootBundle.load('assets/cert/cert.pem');
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());

    String username = await spUtil.GetUsername();
    String password = await spUtil.GetPassword();

    username = "temporary";
    password = "password";

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final connMess = MqttConnectMessage()
        .withClientIdentifier("MarmoApp")
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        .authenticateAs(username, password)
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('marmo::Mosquitto client connecting....');
    client.secure = true;
    client.securityContext = context;
    client.connectionMessage = connMess;
  }

  // 接続初期化(非同期
  void _initConn_test() async {
    // final context = SecurityContext.defaultContext;
    // context.setTrustedCertificates(path.join('assets', 'cert', 'cert.pem'));
    // context.setTrustedCertificates("/assets/cert/cert.pem");
    // ByteData data = await rootBundle.load('assets/cert/cert.pem');
    // context.setTrustedCertificatesBytes(data.buffer.asUint8List());

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
        // .authenticateAs(username, password)
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('marmo::Mosquitto client connecting....');
    // client.secure = true;
    // client.securityContext = context;
    client.connectionMessage = connMess;

    // await client.connect();
  }

  Future connect() async {
    try {
      // await _initConn(); // 接続初期化(非同期
      await _initConn_test(); // 接続初期化(非同期
      var mqttClientConnectionStatus = await client.connect();
      print(
          'marmo::Mosquitto client connect successed.... $mqttClientConnectionStatus');
    } catch (e) {
      print('marmo::Mosquitto client connect failed.... $e');
      return false;
    }
    return true;
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('marmo::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('marmo::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('marmo::OnDisconnected callback is solicited, this is correct');
    }
    exit(-1);
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'marmo::OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    print('marmo::Ping response client callback invoked');
  }

  // デバイス暗号キー配信
  Future<String> getEncryptKey(String deviceName) async {
    String topic = deviceName +
        "/key/" +
        formatDate(DateTime.now(), [yyyy, mm, dd, HH, MM, ss]);
    client.subscribe(topic, MqttQos.exactlyOnce);
    final topicFilter = MqttClientTopicFilter(topic, client.updates);
    // Now listen on the filtered updates, not the client updates
    // ignore: avoid_types_on_closure_parameters
    topicFilter.updates
        .listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage recMess = c[0].payload;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      KeyInfo ki = new KeyInfo();
      final rslt = await ki.jsonToKeyInfo(pt, null);
      if (rslt != null) {
        String jsonKey = rslt.key;
        String keyHeader = ki.getHashedKey();
        if (jsonKey.startsWith(keyHeader)) {
          // DB に保存
          DeviceDBInfo dbInfo = new DeviceDBInfo();
          dbInfo = await DbUtil.dbUtil.getDeviceDBInfoByDeviceName(deviceName);
          dbInfo.key = jsonKey.substring(keyHeader.length - 1);
          dbInfo.keyDate = formatDate(DateTime.now(), [yyyy, mm, dd]);
          DbUtil.dbUtil.updateDeviceDBInfoByName(dbInfo);
        } else {
          // Do nothing
        }
      }
      print(
          'marmo:: Mqtt normal info :: topic is <${c[0].topic}>, payload is <-- $pt -->');
    });
  }

  void subScribePositionByDeviceName(String deviceName) async {
    connect().then((value) async {
      _getPosistionByDeviceName(deviceName);
    });
  }

  // 緯度経度がデバイスから配信
  _getPosistionByDeviceName(String deviceName) async {
    String topic = "/" + deviceName + "/#";
    client.subscribe(topic, MqttQos.exactlyOnce);

    // 通常デバイス情報登録
    final topicFilter = MqttClientTopicFilter(topic, client.updates);
    // Now listen on the filtered updates, not the client updates
    // ignore: avoid_types_on_closure_parameters
    topicFilter.updates
        .listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage recMess = c[0].payload;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      NormalInfo pi = new NormalInfo();
      final rslt = await pi.jsonToNormalinfo(pt, "aaa", null);
      if (rslt) {
        eventBus.fire(pi);
      }
      print(
          'marmo:: Mqtt normal info :: topic is <${c[0].topic}>, payload is <-- $pt -->');
    });
  }

  // デバイス毎に緊急通知購読
  getAllDeviceAlarmInfo() async {
    await connect();
    await getSurroundingUserInfo();
    // getSurroundingUserInfo();
  }

// 緊急通知取得
  getSurroundingUserInfo() async {
    globalTempPos = await geolocator.getCurrentPosition();
    if (globalTempPos == null) {
      return null;
    }
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
    latitude = (latitudeIn10Secs - 1).toString();
    longitude = longitudeIn10Secs.toString();
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
      String topic = "/emg/" +
          latlngMapItem["latitude"] +
          "/" +
          latlngMapItem["longitude"];
      client.subscribe(topic, MqttQos.exactlyOnce);
    });

    // 緊急通知処理登録
    final topicFilter = MqttClientTopicFilter('/emg/#', client.updates);
    var list = await topicFilter.updates.first;
    final MqttPublishMessage recMess = list[0].payload;
    String pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    // TODO: ローカルプッシュ & プッシュpayloadでAlarmInfoを作成＆fire (下記コメント参照
    // AlarmInfo ai = new AlarmInfo();
    // ai.jsonStrToAlarminfo(pt, null);
    // eventBus.fire(ai);
    print(
        'marmo:: Mqtt alarm info :: topic is <${list[0].topic}>, payload is <-- $pt -->');
  }
}
