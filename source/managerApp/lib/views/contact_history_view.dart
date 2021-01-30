import 'package:flutter/material.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/components/my_view_utils.dart';

class ContactHistoryView extends StatelessWidget {
  ContactHistoryView(this.device, this.data, {Key key}) : super(key: key);
  final DeviceDBInfo device;
  final Map<int, Map<String, List<String>>> data;
  static const TITLES = {
    0: '以下の日に濃厚接触者との接触が確認されました。',
    1: '以下の日に陽性者との接触が確認されました。',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${device.name}の過去１４日間の陽性者との接触一覧'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        physics: ScrollPhysics(),
        child: Column(
          children: <Widget>[
            ListView.builder(
              reverse: true,
              shrinkWrap: true,
              itemCount: TITLES.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, caseIndex) {
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: MyText(TITLES[caseIndex]),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data[caseIndex].length,
                      itemBuilder: (context, dayIndex) {
                        var dayData = data[caseIndex].entries.toList();
                        return ExpansionTile(
                          childrenPadding: EdgeInsets.all(0.0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyText(
                                dayData[dayIndex].key,
                                fullWidthNum: false,
                              ),
                              MyText('${dayData[dayIndex].value.length}件'),
                            ],
                          ),
                          children: <Widget>[
                            ListTile(
                              title: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: dayData[dayIndex].value.length,
                                itemBuilder: (context, timeIndex) {
                                  var timeData =
                                      dayData[dayIndex].value.toList();
                                  return Center(
                                    child: Text(timeData[timeIndex]),
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
