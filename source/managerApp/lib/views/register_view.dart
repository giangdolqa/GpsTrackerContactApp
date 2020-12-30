import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:io';

class RegisterView extends StatefulWidget {
  RegisterView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _Register createState() => _Register();
}

class _Register extends State<RegisterView> {
  var _checkBox1 = false;
  final usernameController = TextEditingController();
  final mailController = TextEditingController();
  final phoneController = TextEditingController();
  final loginIdController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();


  _registerUserInfo(String iUsername, String iEmail, String iPhone, String iLoginId, String iPassword, String iRePassword)  {
    if (iUsername.trim().isEmpty) {
      _outputEmptyInfo("お名前を入力してください。");
      return;
    }else if (iEmail.trim().isEmpty) {
      _outputEmptyInfo("メールアドレスを入力してください。");
      return;
    }else if (iPhone.trim().isEmpty) {
      _outputEmptyInfo("電話番号を入力してください。");
      return;
    }else if (iLoginId.trim().isEmpty) {
      _outputEmptyInfo("ログインIDを入力してください。");
      return;
    }else if (iPassword.trim().isEmpty) {
      _outputEmptyInfo("パスワードを入力してください。");
      return;
    }else if (iRePassword.trim().isEmpty) {
      _outputEmptyInfo("パスワードの確認を入力してください。");
      return;
    }else if(RegExp(r"^[a-zA-Z0-9_.+-]+@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$").hasMatch(iEmail.trim()) == false){
      _outputEmptyInfo("メールアドレスが不正です。");
      return;
    }else if(RegExp(r"^0\d{1,4}-\d{1,4}-\d{4}$").hasMatch(iPhone.trim()) == false){
      _outputEmptyInfo("電話番号に半角数字「-」を正しく入力ください。");
      return;
    }else if(RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(iLoginId.trim()) == false){
      _outputEmptyInfo("ログインIDに半角英数アンダーバー以外があります。");
      return;
    }else if(RegExp(r"^[a-zA-Z0-9!-/:-@¥[-`{-~]+$").hasMatch(iPassword.trim()) == false){
      _outputEmptyInfo("パスワードに半角英数記号以外があります。");
      return;
    }else if(iPassword.trim()!=iRePassword.trim()){
      _outputEmptyInfo("2回入力したパスワードが不一致です。");
      return;
    }else{}
    // 2段階認証関連処理、ここに追加
  }

  _outputEmptyInfo(String iErrInfo){
    Widget cancelButton = FlatButton(
      child: Text("OK"),
      onPressed:  () {Navigator.of(context).pop();},
    );
    AlertDialog alert = AlertDialog(
      title: Text("入力エラー"),
      content: Text(iErrInfo),
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
    usernameController.dispose();
    mailController.dispose();
    phoneController.dispose();
    loginIdController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
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
                    child: Text('GPSトラッカー（仮）へ登録', style: TextStyle(fontSize: 14),),
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
                    child: Text('お名前', style: TextStyle(fontSize: 14),),
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
                      controller: usernameController,
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
                    child: Text('メールアドレス', style: TextStyle(fontSize: 14),),
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
                      controller: mailController,
                      keyboardType:TextInputType.visiblePassword,  // 日本語を回避
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
                    child: Text('電話番号', style: TextStyle(fontSize: 14),),
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
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
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
                    child: Text('ログインID', style: TextStyle(fontSize: 14),),
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
                      controller: loginIdController,
                      keyboardType: TextInputType.visiblePassword,  // 半角に制限のため
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
                    child: Text('パスワード', style: TextStyle(fontSize: 14),),
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
                      controller: passwordController,
                      obscureText: !_checkBox1,
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
                    child: Text('パスワードの確認', style: TextStyle(fontSize: 14),),
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
                      controller: passwordConfirmController,
                      obscureText: !_checkBox1,
                      keyboardType: TextInputType.visiblePassword,  // 半角に制限のため
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
                    width: size.width / 32 * 31,
                    height: maxHeight / 32,
                    child:
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                          value: _checkBox1,
                          onChanged: (bool value) {
                            this.setState((){
                              _checkBox1 = value;
                            });
                          },
                        ),
                        Text("パスワードを表示"),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container( // 上下配置調整
                    width: size.width,
                    height: maxHeight / 64,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: size.width / 32 * 12,
                      height: maxHeight / 16,
                      child: FlatButton(
                        onPressed: () {
                          //print( kToolbarHeight);
                          _registerUserInfo(usernameController.text,
                            mailController.text,
                            phoneController.text,
                            loginIdController.text,
                            passwordController.text,
                            passwordConfirmController.text,);
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Text(
                          '登録',
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