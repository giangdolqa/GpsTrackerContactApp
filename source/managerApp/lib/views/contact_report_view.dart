import 'package:flutter/material.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/components/my_view_utils.dart';

class ContactReportView extends StatefulWidget {
  const ContactReportView(this.device, {Key key}) : super(key: key);
  final DeviceDBInfo device;

  @override
  _ContactReportViewState createState() => _ContactReportViewState(device);
}

class _ContactReportViewState extends State<ContactReportView> {
  final DeviceDBInfo device;
  bool _showKey = false;

  _ContactReportViewState(this.device);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${device.name}の濃厚接触情報の登録'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        physics: ScrollPhysics(),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: MyText('学校ID'),
            ),
            TextField(
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            Container(
              width: double.infinity,
              child: MyText('キー'),
            ),
            TextField(
              obscureText: !_showKey,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 30.0,
                  child: Checkbox(
                    value: this._showKey,
                    onChanged: (val) => setState(() {
                      this._showKey = val;
                    }),
                  ),
                ),
                MyText('キーを表示'),
              ],
            ),
            Center(
              child: MyButton('送信'),
            ),
          ],
        ),
      ),
    );
  }
}
