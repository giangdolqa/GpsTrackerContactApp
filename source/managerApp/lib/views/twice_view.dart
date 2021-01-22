import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';

class TwiceCheckView extends StatefulWidget {
  final String loginId;
  TwiceCheckView({Key key, this.loginId}): super(key: key);

  @override
  _TwiceCheck createState() => _TwiceCheck(loginId);
}

class _TwiceCheck extends State<TwiceCheckView> {
  final mailCodeController = TextEditingController();
  final smsCodeController = TextEditingController();
  final String loginId;
  final String url = "http://ik1-407-35954.vs.sakura.ne.jp:3000/api/v1/";
  final Map<String, String> headers = {"Content-type": "application/json"};

  _TwiceCheck(this.loginId);
  _twiceCheck(String iMailCode, String iSmsCode) async {
    if (iMailCode.trim().isEmpty) {
      _outputInfo("入力エラー", "メールのコードを入力してください。");
      return;
    }else if (iSmsCode.trim().isEmpty) {
      _outputInfo("入力エラー", "SMSのコードを入力してください。");
      return;
    }else{}



    var pleasanterJson = {
      "LoginID":"suzuki001",
      "MailCode":iMailCode.trim().toString(),
      "SmsCode":iSmsCode.trim().toString(),
    };

    Response response = await patch(url + "auth/verify", headers: headers, body: json.encode(pleasanterJson));
    print(iMailCode.trim().toString());
    print(iSmsCode.trim().toString());
    if (response.statusCode == 200) {
      _outputInfo("認証成功", "一時パスワード:"+ json.decode(response.body).toString());
    }else if (response.statusCode == 400){
      _outputInfo("認証失敗", "認証コード期限切れです。");
    }else if (response.statusCode == 401){
      _outputInfo("認証失敗", "認証コードが間違います。");
    }else if (response.statusCode == 402){
      _outputInfo("認証失敗", "一時パスワードなしです。");
    }else{
      _outputInfo("認証失敗", "応答コード:" + response.statusCode.toString());
    }
  }

  _reCheck() async{
    Response res = await patch(url + "auth/request", headers: headers, body: json.encode(
        {"LoginID":"suzuki001"}));
  }

  _outputInfo(String iTitle, String iInfo){
    Widget cancelButton = FlatButton(
      child: Text("OK"),
      onPressed:  () {Navigator.of(context).pop();},
    );
    AlertDialog alert = AlertDialog(
      title: Text(iTitle),
      content: Text(iInfo),
      actions: [
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  // widgetの破棄時にコントローラも破棄する
  void dispose() {
    mailCodeController.dispose();
    smsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    var maxHeight = size.height - padding.top - padding.bottom;

    if (Platform.isAndroid) {
      maxHeight = size.height - padding.top - kToolbarHeight;
    } else if (Platform.isIOS) {
      maxHeight = size.height - padding.top - padding.bottom - 22;
    }
    return Scaffold(
      //appBar: AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      //title: Text(widget.title, style: TextStyle(fontSize: 14,color: Colors.black)),
      //backgroundColor: Colors.white,
      //),
      body: DropdownButtonHideUnderline(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SafeArea(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          top: false,
          bottom: false,
          child: new ListView(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 上部の幅調整
                    width: size.width,
                    height: maxHeight / 64,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 左揃え用
                    width: size.width / 32 * 1,
                    height: maxHeight / 16,
                  ),
                  Container(
                    width: size.width / 32 * 31,
                    height: maxHeight / 16,
                    child: Text('marmoへ登録', style: TextStyle(fontSize: 14),),
                  ),
                ],
              ),
              Divider(
                height: 0,
                thickness: 2,
                color: Colors.blue[50],
                indent: size.width / 32 * 1,
                endIndent: size.width / 32 * 1,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 配置調整
                    width: size.width,
                    height: maxHeight / 64,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 左揃え用
                    width: size.width / 32 * 1,
                    height: maxHeight / 32,
                  ),
                  Container(
                    width: size.width / 32 * 30,
                    height: maxHeight / 32,
                    child: Text('メールのコード', style: TextStyle(fontSize: 14),),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 左揃え用
                    width: size.width / 32 * 1,
                    height: maxHeight / 16,
                  ),
                  Container(
                    width: size.width / 32 * 30,
                    height: maxHeight / 16,
                    child: TextField(
                      controller: mailCodeController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  Container( // 右揃え用
                    width: size.width / 32 * 1,
                    height: maxHeight / 16,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 配置調整
                    width: size.width,
                    height: maxHeight / 64,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 左揃え用
                    width: size.width / 32 * 1,
                    height: maxHeight / 32,
                  ),
                  Container(
                    width: size.width / 32 * 30,
                    height: maxHeight / 32,
                    child: Text('SMSのコード', style: TextStyle(fontSize: 14),),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 左揃え用
                    width: size.width / 32 * 1,
                    height: maxHeight / 16,
                  ),
                  Container(
                    width: size.width / 32 * 30,
                    height: maxHeight / 16,
                    child: TextField(
                      controller: smsCodeController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  Container( // 右揃え用
                    width: size.width / 32 * 1,
                    height: maxHeight / 16,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 上下配置調整
                    width: size.width,
                    height: maxHeight / 32,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: size.width / 32 * 10,
                      height: maxHeight / 16,
                      child: FlatButton(
                        onPressed: () {
                          _reCheck();
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Text(
                          '再発行',
                          style: TextStyle(
                              color:Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                      )
                  ),
                  Container( // 左揃え用
                    width: size.width / 32 * 1,
                    height: maxHeight / 12,
                  ),
                  Container(
                      width: size.width / 32 * 10,
                      height: maxHeight / 16,
                      child: FlatButton(
                        onPressed: () {
                          _twiceCheck(
                              mailCodeController.text,
                              smsCodeController.text);
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Text(
                          '確認',
                          style: TextStyle(
                              color:Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}