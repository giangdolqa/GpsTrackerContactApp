import 'dart:io';

import 'package:flutter/material.dart';
import 'package:marmo/beans/device_dbInfo.dart';
import 'package:marmo/components/my_view_utils.dart';
import 'package:marmo/utils/rest_util.dart';

class ContactRegisterView extends StatefulWidget {
  const ContactRegisterView(this.device, this.type, {Key key}) : super(key: key);
  final DeviceDBInfo device;
  final int type;

  @override
  _ContactRegisterViewState createState() => _ContactRegisterViewState(device, type);
}

class _ContactRegisterViewState extends State<ContactRegisterView> {
  static const TITLES = {
    0: 'の濃厚接触情報の登録',
    1: 'の濃陽性情報の登録',
  };
  final DeviceDBInfo device;
  final int type;
  bool _agree = false;
  bool _requestBtnLoading = false;
  bool _submitBtnLoading = false;

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
              child: MyText('デバイスと接触した履歴のある人に通知が行きます。登録は氏名や連絡先などの個人情報を登録する必要はありません。'
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
                MyButton(
                  '再発行',
                  onPressed: !_agree || _requestBtnLoading ? null : _requestCodeClick,
                ),
                MyButton(
                  '登録',
                  onPressed: !_agree || _submitBtnLoading ? null : _registerClick,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _requestCodeClick() async {
    try {
      setState(() => _requestBtnLoading = true);
      var req = await restUtil.requestEmailCode(context);
      if (req.statusCode != 200) {
        throw Exception(req.statusCode);
      } else {
        await Future.delayed(Duration(seconds: 30));
      }
    } catch (e) {
      print(e);
      await ViewUtils.showSimpleDialog(context, 'Unexpected error!', e.toString());
    } finally {
      setState(() => _requestBtnLoading = false);
    }
  }

  _registerClick() async {
    try {
      setState(() => _submitBtnLoading = true);
      var verify = await restUtil.requestEmailCode(context);
      if (verify.statusCode == HttpStatus.ok) {
        var register = await restUtil.register(device, type);
        if (register.statusCode == HttpStatus.ok) {
          Navigator.pop(context);
        } else {
          throw Exception(register.statusCode);
        }
      } else if (verify.statusCode == HttpStatus.badRequest) {
        await ViewUtils.showSimpleDialog(context, '認証コード期限切れ');
      } else if (verify.statusCode == HttpStatus.unauthorized) {
        await ViewUtils.showSimpleDialog(context, '認証コードの間違い');
      } else if (verify.statusCode == HttpStatus.paymentRequired) {
        await ViewUtils.showSimpleDialog(context, '一時パスワードなし');
      } else {
        throw Exception(verify.statusCode);
      }
    } catch (e) {
      print(e);
      await ViewUtils.showSimpleDialog(context, 'Unexpected error!', e.toString());
    } finally {
      setState(() => _submitBtnLoading = false);
    }
  }
}
