import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import 'position_util.dart';
import 'shared_pre_util.dart';


class HttpUtil {
  /// global dio object
  static Dio dio;

  /// default options
  static const String API_PREFIX =
//      'http://192.168.207.97:8081/dummy/driver/'; // Home
//      'http://127.0.0.1:8081/dummy/driver/'; // Local
      'http://192.168.31.216:8081/dummy/driver/'; // Office
//      'http://192.168.31.87:8081/dummy/driver/'; // Office Me
//      'http://210.251.91.205/api/driver/'; // Production
  static const int CONNECT_TIMEOUT = 10000;
  static const int RECEIVE_TIMEOUT = 3000;

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  static final spUtil = SharedPreUtil();

  /// request method
  static Future<Map> request(String url, {data, method}) async {
    data = data ?? {};
    method = method ?? 'GET';

    // If phoneNum is not set, set phoneNum
    if (!data.containsKey("phoneNum")) {
      String phoneNum = await spUtil.GetPhoneNum();
//      //print("Get phoneNum : " + phoneNum);
      data["phoneNum"] = phoneNum;
    }

    /// restful request convert
    /// eg: /login/:user_id (user_id=27) => /login/27
    var tempData = new Map.from(data);
    tempData.forEach((key, value) {
      if (url.indexOf(':$key') != -1) {
        url = url.replaceAll(':$key', value.toString());
        data.remove(key);
      }
    });



    String curToken = await spUtil.GetToken(); // Place Token here
    if (curToken != null) {
      //print('<DIO> request token: ' + curToken);
    }
    Dio dio = createInstance(curToken);
    var result;

    Position position = await positionUtil.GetCurrentPos();
    Map<String, dynamic> headersWithPos;
    if (position != null) {
      headersWithPos = {
        HttpHeaders.authorizationHeader: curToken,
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
        "speed": position.speed.toString(),
        "direction": globalDirection != null ? globalDirection.toString() : position.heading.toString()
      };
    } else {
      headersWithPos = {HttpHeaders.authorizationHeader: curToken, "latitude": "", "longitude": "", "speed": "", "direction": ""};
    }

    /// request log print
//    print('<DIO> request URL: [' + method + '  ' + url + ']');
//    print('<DIO> request Header' + headersWithPos.toString());
//    print('<DIO> request parameter' + data.toString());

    try {
      Response response = await dio.request(url,
          data: data,
          options: new Options(
            method: method,
            headers: headersWithPos,
//            contentType: ContentType.json.toString(),
          ));

      result = response.data;

      /// response log print
//      print('<DIO> response: ' + response.toString());
    } on DioError catch (e) {
      /// response error print
      print('<DIO> error   : ' + e.toString());
    }

    Map<String, dynamic> jsonDataMap = jsonDecode(result);
    return jsonDataMap;
  }

  /// Create dio instance
  static Dio createInstance(String authToken) {
    if (dio == null) {
      /// global config
      BaseOptions options = BaseOptions(
        headers: {HttpHeaders.authorizationHeader: authToken},
        baseUrl: API_PREFIX,
        connectTimeout: CONNECT_TIMEOUT,
        receiveTimeout: RECEIVE_TIMEOUT,
      );

      dio = new Dio(options);
    }
    return dio;
  }

  /// Clear up dio instance
  static clear() {
    dio = null;
  }

  static Future uploadRequest(url, {map}) async {
    String curToken = await spUtil.GetToken(); // Place Token here
    Dio dio = createInstance(curToken);

    FormData formData;
    formData = FormData.fromMap(map);

    /// request log print
    print('<DIO> request URL: [' + POST + '  ' + url + ']');
    print('<DIO> request file upload!');
//    if (curToken != null) {
//      print('<DIO> request token: ' + curToken);
//    }

    var result;

    try {
      Position position = await positionUtil.GetCurrentPos();
      Map<String, dynamic> headersWithPos;
      if (position != null) {
        headersWithPos = {
          HttpHeaders.authorizationHeader: curToken,
          "latitude": position.latitude.toString(),
          "longitude": position.longitude.toString(),
          "speed": position.speed.toString(),
          "direction": globalDirection != null ? globalDirection.toString() : position.heading.toString()
        };
      } else {
        headersWithPos = {HttpHeaders.authorizationHeader: curToken, "latitude": "", "longitude": "", "speed": "", "direction": ""};
      }

      print('<DIO> request Upload Header' + headersWithPos.toString());

      Response response = await dio.request(
        url,
        data: formData,
        options: new Options(method: POST, headers: headersWithPos),
      );

      result = response.data;

      /// response log print
      print('<DIO> response: ' + response.toString());
    } on DioError catch (e) {
      /// response error print
      print('<DIO> error   : ' + e.toString());
    }

    Map<String, dynamic> jsonDataMap = jsonDecode(result);
    return jsonDataMap;
  }

  static Future<File> getNetImage(String strPath, String strUrl) async {
    try {
//      new HttpClient().getUrl(Uri.parse(strUrl));
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path + strPath;
      HttpClientRequest httpRequest = await HttpClient().getUrl(Uri.parse(strUrl));
      HttpClientResponse response = await httpRequest.close();
      File localFile = await response.pipe(new File(tempPath).openWrite());
      return localFile;
    } catch (e) {
      //print('<HTTP_UTIL> getNetImage error   : ' + e.toString());
      return null;
    }
  }
}
