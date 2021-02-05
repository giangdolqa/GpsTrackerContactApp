import 'package:flutter/material.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/components/my_view_utils.dart';
import 'package:marmo/utils/db_util.dart';
import 'package:marmo/utils/mqtt_util.dart';

class ContactReportView extends StatefulWidget {
  const ContactReportView(this.device, {Key key}) : super(key: key);
  final DeviceDBInfo device;

  @override
  _ContactReportViewState createState() => _ContactReportViewState(device);
}

class _ContactReportViewState extends State<ContactReportView> {
  final DeviceDBInfo device;
  TextEditingController _idController;
  TextEditingController _keyController;
  bool _showKey = false;

  _ContactReportViewState(this.device);

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _keyController = TextEditingController();
    _idController.text = device.reportId;
    _keyController.text = device.reportKey;
  }

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
              controller: _idController,
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
              controller: _keyController,
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
              child: MyButton(
                '送信',
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _send() async {
    _updateReportAccount(_idController.text, _keyController.text);
    await mqttUtil.sendDeviceKey(_idController.text, _keyController.text);
    Navigator.pop(context);
  }

  _updateReportAccount(String reportId, String reportKey) async {
    DeviceDBInfo dbInfo = await marmoDB.getDeviceDBInfoByDeviceId(device.id);
    if (dbInfo != null) {
      dbInfo.reportId = reportId;
      dbInfo.reportKey = reportKey;
      marmoDB.updateDeviceDBInfo(dbInfo);
    }
  }
}
