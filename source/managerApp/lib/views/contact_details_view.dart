import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/components/my_view_utils.dart';
import 'package:marmo/utils/db_util.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_history_view.dart';
import 'contact_register_view.dart';
import 'contact_report_view.dart';

class ContactDetailsView extends StatelessWidget {
  ContactDetailsView(this.device, {Key key}) : super(key: key);
  final DeviceDBInfo device;

  updateReportAccount(String reportId, String reportKey) async {
    DeviceDBInfo dbInfo = await marmoDB.getDeviceDBInfoByDeviceId(device.id);
    if (dbInfo != null) {
      dbInfo.reportId = reportId;
      dbInfo.reportKey = reportKey;
      marmoDB.updateDeviceDBInfo(dbInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${device.name} 接触確認'),
      ),
      body: FutureBuilder<Map<int, Map<String, List<String>>>>(
        future: _fetchContactInfo(device),
        builder: (context, snapshot) {
          Widget mainChild;

          if (snapshot.hasData) {
            mainChild = SingleChildScrollView(
              padding: EdgeInsets.all(8.0),
              physics: ScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Icon(
                      Icons.info_rounded,
                      color: snapshot.data.isEmpty ? Colors.blue : Colors.red,
                      size: 60,
                    ),
                  ),
                  snapshot.data.isEmpty
                      ? Column(
                          children: [
                            Container(
                              width: double.infinity,
                              child: MyText('陽性者、濃厚接触者との接触は確認されませんでした。'),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: double.infinity,
                              child: MyText('陽性者との接触が確認されました。'),
                            ),
                            Container(
                              child: MyText(
                                '${snapshot.data[1].length}件',
                                color: Colors.red,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: MyText('濃厚接触者との接触が確認されました。'),
                            ),
                            Container(
                              child: MyText(
                                '${snapshot.data[1].length}件',
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        snapshot.data.isEmpty
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.symmetric(horizontal: 35.0),
                                child: MyButton(
                                  '受診・相談センターのサイト',
                                  onPressed: () => launch('https://google.com'),
                                ),
                              ),
                        snapshot.data.isEmpty
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.symmetric(horizontal: 35.0),
                                child: MyButton(
                                  '接触一覧',
                                  page: ContactHistoryView(device, snapshot.data),
                                ),
                              ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(width: 35.0),
                            Expanded(
                              child: Container(
                                constraints: BoxConstraints(minWidth: 350.0),
                                child: MyButton(
                                  '学校に報告',
                                  page: ContactReportView(device),
                                ),
                              ),
                            ),
                            Container(
                              width: 35.0,
                              child: (device.reportId == null && device.reportKey == null)
                                  ? Container()
                                  : StatefulBuilder(
                                      builder: (context, setState) {
                                        return FlatButton(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
                                          child: Icon(Icons.cancel, size: 35.0),
                                          padding: EdgeInsets.all(0),
                                          onPressed: () {},
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                        snapshot.data.isEmpty
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.symmetric(horizontal: 35.0),
                                child: MyButton('濃厚接触の登録', page: ContactRegisterView(device, 0)),
                              ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 35.0),
                          child: MyButton(
                            '要請情報の登録',
                            page: ContactRegisterView(device, 1),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            mainChild = MyLoadError(snapshot.error.toString());
          } else {
            mainChild = MyLoading();
          }
          return mainChild;
        },
      ),
    );
  }

  Future<Map<int, Map<String, List<String>>>> _fetchContactInfo(DeviceDBInfo device) async {
    // var contactInfo = json.decode((await restUtil.getContactInfo(device)).body);
    //GiAnG test data
    var contactInfo = json.decode(device.name.length < 5
        ? '[]'
        : '''
    [
   {
      "Time":20210115091123,
      "Type":1,
      "RPI":"07d635658f82c3c4b8fb211f1e0634a"
   },
   {
      "Time":20210115091023,
      "Type":1,
      "RPI":"07d635658f82c3c4b8fb211f1e0634a"
   },
   {
      "Time":20210116091123,
      "Type":0,
      "RPI":"07d635658f82c3c4b8fb211f1e0634a"
   },
   {
      "Time":20210115090923,
      "Type":0,
      "RPI":"07d635658f82c3c4b8fb211f1e0634a"
   },
   {
      "Time":20210116091123,
      "Type":1,
      "RPI":"07d635658f82c3c4b8fb211f1e0634a"
   },
   {
      "Time":20210116091023,
      "Type":1,
      "RPI":"07d635658f82c3c4b8fb211f1e0634a"
   },
   {
      "Time":20210116091123,
      "Type":0,
      "RPI":"07d635658f82c3c4b8fb211f1e0634a"
   },
   {
      "Time":20210116090923,
      "Type":0,
      "RPI":"07d635658f82c3c4b8fb211f1e0634a"
   }
]
    ''');
    var result = <int, Map<String, List<String>>>{};
    if (contactInfo is List) {
      for (var item in contactInfo) {
        var type = item['Type'];

        var time = item['Time'].toString();
        var year = time.substring(0, 4);
        var month = time.substring(4, 6);
        var day = time.substring(6, 8);
        var hour = time.substring(8, 10);
        var minute = time.substring(10, 12);

        var formatDate = '$year/$month/$day';
        var formatTime = '$hour:$minute';

        var groupByCase = (result[type] ??= <String, List<String>>{});
        var groupByDay = (groupByCase[formatDate] ??= []);
        groupByDay.add(formatTime);
      }
    }
    return result;
  }
}
