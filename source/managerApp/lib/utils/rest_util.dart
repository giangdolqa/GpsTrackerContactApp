import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/utils/shared_pre_util.dart';

final restUtil = RestUtil();

class RestUtil {
  static const ROOT = 'http://ik1-407-35954.vs.sakura.ne.jp:3000/api/v1';

  Future<Response> _call(String method, String path, Map<String, dynamic> body) async {
    print('REST called: $method, $path, $body');
    return await Response.fromStream(await (Request(method, Uri.parse('$ROOT/$path'))
          ..headers['Content-Type'] = 'application/json'
          ..body = json.encode(body))
        .send());
  }

  Future<Response> requestEmailCode(BuildContext context) async {
    return await _call('PATCH', 'auth/request/sms', {
      'LoginID': await spUtil.GetLoginID(),
    });
  }

  Future<Response> verifyEmailCode(BuildContext context) async {
    return await _call('PATCH', 'auth/verify/mail', {
      'LoginID': await spUtil.GetLoginID(),
    });
  }

  Future<dynamic> register(DeviceDBInfo deviceDBInfo, int type) async {
    return _call('POST', {0: 'contact', 1: 'positive'}[type], {
      'ID': deviceDBInfo.id,
      'LoginID': await spUtil.GetLoginID(),
      'data': deviceDBInfo.tekList
          .map((e) => {
                'Time': e.time,
                'TEK': e.tek,
                'ENIN': e.eninList,
              })
          .toList(),
    });
  }

  Future<Response> getContactInfo(DeviceDBInfo deviceDBInfo) {
    return _call('GET', 'contact', {
      'data': deviceDBInfo.rpiList
          .map((e) => {
                'Time': e.time,
                'RPI': e.rpi,
              })
          .toList(),
    });
  }
}
