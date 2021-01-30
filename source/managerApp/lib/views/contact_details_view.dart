import 'package:flutter/material.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/components/my_view_utils.dart';
import 'package:marmo/others/test_data_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_history_view.dart';
import 'contact_register_view.dart';
import 'contact_report_view.dart';

class ContactDetailsView extends StatelessWidget {
  ContactDetailsView(this.device, {Key key}) : super(key: key);
  final DeviceDBInfo device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${device.name} 接触確認'),
      ),
      body: FutureBuilder<Map<int, Map<String, List<String>>>>(
        future: TestDataUtils.fetchContactInfo(device),
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
                                  page:
                                      ContactHistoryView(device, snapshot.data),
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
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35.0)),
                                child: Icon(Icons.cancel, size: 35.0),
                                padding: EdgeInsets.all(0),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        snapshot.data.isEmpty
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.symmetric(horizontal: 35.0),
                                child: MyButton('濃厚接触の登録',
                                    page: ContactRegisterView(device, 0)),
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
            mainChild = MyLoadError();
          } else {
            mainChild = MyLoading();
          }
          return mainChild;
        },
      ),
    );
  }
}
