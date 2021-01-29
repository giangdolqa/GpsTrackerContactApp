// Mqtt通信ツール
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/beans/key_info.dart';
import 'package:marmo/beans/normal_info.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:toast/toast.dart';

import 'db_util.dart';
import 'event_util.dart';
import 'position_util.dart';
import 'shared_pre_util.dart';

final MqttUtil mqttUtil = MqttUtil();

class MqttUtil {
  final client = MqttServerClient('ik1-407-35954.vs.sakura.ne.jp', '');

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
    client.port = 8883; // 実装用
    // client.port = 1883; // 実装用

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
    ByteData data = await rootBundle.load('assets/cert/cert.pem');
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());

    String username = await spUtil.GetUsername();
    String password = await spUtil.GetPassword();
    username = "TEST";
    password = "test";

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
    client.autoReconnect = true;
    client.securityContext = context;
    client.connectionMessage = connMess;
  }

  Future connect() async {
    try {
      await _initConn(); // 接続初期化(非同期
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
    // exit(-1);
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

  // 登録済みデバイス暗号キー配信 & 位置情報取得
  void subScribeAllPositionInfoAndKey(BuildContext context) async {
    if (client.connectionStatus.state == MqttConnectionState.disconnected) {
      await connect();
    }
    // 接続成功時のみ続行
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      List<DeviceDBInfo> deviceList = await marmoDB.getDeviceDBInfoList();
      for (DeviceDBInfo deviceInfo in deviceList) {
        await _getPosistionByDeviceNameAndKey(deviceInfo.name);
      }
    } else {
      Toast.show("Mqttサーバーと接続失敗しました。", context);
    }
  }

  // deviceNameでデバイス暗号キー配信 & 位置情報取得
  _getPosistionByDeviceNameAndKey(String deviceName) async {
    String topic = deviceName + "/#";
    // client.subscribe(topic, MqttQos.atMostOnce);
    // 0 （購読topicがデバイス暗号配信と同じため、購読側はQoS 2とする）
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
      final String topic = c[0].topic;
      final String subTopic = topic.split("/")[1];
      if (subTopic == "key") {
        // デバイス暗号配信購読処理
        KeyInfo ki = new KeyInfo();
        final rslt = await ki.jsonToKeyInfo(pt, null);
        if (rslt != null) {
          String jsonKey = rslt.key;
          String keyHeader = ki.getHashedKey(c[0].topic);
          if (jsonKey.startsWith(keyHeader)) {
            // DB に保存
            DeviceDBInfo dbInfo = new DeviceDBInfo();
            dbInfo = await marmoDB.getDeviceDBInfoByDeviceName(deviceName);
            dbInfo.key = jsonKey.substring(keyHeader.length - 1);
            dbInfo.keyRule = json.encoder.convert(ki.name); // Serialize
            dbInfo.keyDate = formatDate(DateTime.now(), [yyyy, mm, dd]);
            marmoDB.updateDeviceDBInfoByName(dbInfo);
          } else {
            // Do nothing
          }
        } else {
          //
        }
      } else {
        // デバイス情報配信 購読処理
        NormalInfo pi = new NormalInfo();
        final rslt = await pi.jsonToNormalinfo(pt, deviceName, null);
        if (rslt) {
          eventBus.fire(pi);
        }
        print(
            'marmo:: Mqtt normal info :: topic is <${c[0].topic}>, payload is <-- $pt -->');
      }
    });
  }

// 緊急通知取得
  getSurroundingAlarmInfo(BuildContext context) async {
    if (client.connectionStatus.state == MqttConnectionState.disconnected) {
      await connect();
    }

    // 接続成功時のみ続行
    if (client.connectionStatus.state == MqttConnectionState.connected) {
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
        String topic = "+/emg/" +
            latlngMapItem["latitude"] +
            "/" +
            latlngMapItem["longitude"];
        client.subscribe(topic, MqttQos.exactlyOnce);
      });

      // 緊急通知処理登録

      final topicFilter = MqttClientTopicFilter('+/emg/#', client.updates);
      topicFilter.updates.listen((mqttMessage) {
        String deviceName = mqttMessage[0].topic.split("/")[0];
        final MqttPublishMessage recMess = mqttMessage[0].payload;
        String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        // TODO: ローカルプッシュ & プッシュpayloadでAlarmInfoのListを作成 (下記コメント参照
        // DEBUG -S-
        // List<AlarmInfo> alarmList = [];
        // AlarmInfo ai = new AlarmInfo();
        // try {
        //   ai.jsonStrToAlarminfo(pt, null);
        //   ai.deviceName = deviceName;
        //   alarmList.add(ai);
        // } catch (e) {
        //   print("marmo:: Mqtt alarm item unrecognized :: $e ");
        // }
        // print(
        //     'marmo:: Mqtt alarm info :: topic is <${mqttMessage[0].topic}>, payload is <-- $pt -->');
        // eventBus.fire(alarmList);
        // DEBUG -E-
      });
    } else {
      if (context != null) {
        Toast.show("Mqttサーバーと接続失敗しました。", context);
      }
    }
  }

// 緊急通知引き続き判定
  getAlarmInfoOn(BuildContext context, String deviceName) async {
    if (client.connectionStatus.state == MqttConnectionState.disconnected) {
      await connect();
    }
    // 接続成功時のみ続行
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      globalTempPos = await geolocator.getCurrentPosition();
      if (globalTempPos == null) {
        return null;
      }

      String topic = deviceName + "/emg/#";

      client.subscribe(topic, MqttQos.exactlyOnce);

      // 緊急通知あるかを確認
      final topicFilter = MqttClientTopicFilter(topic, client.updates);
      try {
        // 緊急情報がある場合は１秒間隔で確認を行い、１秒を超えてメッセージが配信されていなければ、削除する
        var mqttMessage =
            await topicFilter.updates.first.timeout(Duration(seconds: 1));
        print('marmo:: Mqtt alarm info on');
        if (mqttMessage[0].topic != null) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print('marmo:: Mqtt alarm info off : $e');
        return false;
      }
    } else {
      if (context != null) {
        Toast.show("Mqttサーバーと接続失敗しました。", context);
      }
    }
  }
}
