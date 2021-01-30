import 'dart:math';

import 'package:intl/intl.dart';
import 'package:marmo/beans/device_dbInfo.dart';

class TestDataUtils {
  static final Future<List<DeviceDBInfo>> devicesFuture =
      Future<List<DeviceDBInfo>>.delayed(
    Duration(seconds: 1),
    () {
      List<DeviceDBInfo> result = [
        DeviceDBInfo()..name = "Peter",
        DeviceDBInfo()..name = "John",
        DeviceDBInfo()..name = "Terry",
      ];
      return result;
    },
  );

  static Future<Map<int, Map<String, List<String>>>> fetchContactInfo(
      DeviceDBInfo device) {
    return Future<Map<int, Map<String, List<String>>>>.delayed(
      Duration(seconds: 1),
      () {
        var d1 = DateTime.parse('2020-01-01');
        var rand = Random();
        var list = <DateTime>[];
        for (var i = 0; i < 20; i++) {
          var dateTime = DateTime.fromMillisecondsSinceEpoch(
              d1.millisecondsSinceEpoch +
                  Duration(
                          days: rand.nextInt(5),
                          hours: rand.nextInt(20),
                          minutes: rand.nextInt(50),
                          seconds: rand.nextInt(10000))
                      .inMilliseconds);
          list.add(dateTime);
        }
        list.sort();

        var map = <int, Map<String, List<String>>>{};

        for (var dateTime in list) {
          var groupByCase = (map[rand.nextInt(2)] ??= <String, List<String>>{});
          var groupByDay =
              (groupByCase[DateFormat('dd/MM/yyyy').format(dateTime)] ??= []);
          groupByDay.add(DateFormat.Hm().format(dateTime));
        }
        return device.name.length % 2 == 0 ? {} : map;
      },
    );
  }
}
