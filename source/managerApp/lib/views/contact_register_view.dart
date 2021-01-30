import 'package:flutter/material.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/components/my_view_utils.dart';

class ContactRegisterView extends StatefulWidget {
  const ContactRegisterView(this.device, this.type, {Key key})
      : super(key: key);
  final DeviceDBInfo device;
  final int type;

  @override
  _ContactRegisterViewState createState() =>
      _ContactRegisterViewState(device, type);
}

class _ContactRegisterViewState extends State<ContactRegisterView> {
  static const TITLES = {
    0: 'の濃厚接触情報の登録',
    1: 'の濃陽性情報の登録',
  };
  final DeviceDBInfo device;
  final int type;
  bool _agree = false;

  _ContactRegisterViewState(this.device, this.type);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${device.name}${TITLES[type]}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        physics: ScrollPhysics(),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: MyText(
                  'デバイスと接触した履歴のある人に通知が行きます。登録は氏名や連絡先などの個人情報を登録する必要はありません。'
                  'また、接触した場所の位置情報が記録や通知されることもありません。登録してもよろしいですか？'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 30.0,
                  child: Checkbox(
                    value: this._agree,
                    onChanged: (val) => setState(() => this._agree = val),
                  ),
                ),
                MyText('同意'),
              ],
            ),
            Container(
              width: double.infinity,
              child: MyText('メールのコードを入力してください'),
            ),
            TextField(
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MyButton('再発行'),
                MyButton('登録'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
