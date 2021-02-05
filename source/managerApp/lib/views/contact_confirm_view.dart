import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/components/my_view_utils.dart';
import 'package:marmo/utils/db_util.dart';

import 'contact_details_view.dart';

class ContactConfirmView extends StatelessWidget {
  ContactConfirmView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("接触確認")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        physics: ScrollPhysics(),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Text('陽性者との接触の記録は１４日間保存されます。'),
            ),
            FutureBuilder<List<DeviceDBInfo>>(
              future: marmoDB.getLatestDeviceDBInfoList(),
              builder: (context, snapshot) {
                Widget mainChild;
                if (snapshot.hasData) {
                  mainChild = ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                            child: Text('${snapshot.data[index].name}' + (index == 0 ? ' (ご自分)' : '')),
                          ),
                          Container(
                            padding: EdgeInsets.all(4.0),
                            child: MyText(
                              DateFormat('yyyy年MM月dd日から４０日間使用中').format(snapshot.data[index].created),
                              small: true,
                            ),
                          ),
                          MyButton(
                            "陽性者との接触を確認する",
                            page: ContactDetailsView(snapshot.data[index]),
                          ),
                        ],
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  mainChild = MyLoadError(snapshot.error.toString());
                } else {
                  mainChild = MyLoading();
                }
                return mainChild;
              },
            ),
          ],
        ),
      ),
    );
  }
}
