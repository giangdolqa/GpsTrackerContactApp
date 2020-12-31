import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'dart:convert';

class LoginView extends StatefulWidget {
  LoginView({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  var _checkBox1 = false;
  final loginIdController = TextEditingController();
  final passwordController = TextEditingController();
  final String server = "203.137.100.55/pleasanter";
  final String sideId = "3";
  final String apiKey = "56161eb08314a9b7e5b49f85de53df6d8613f6f96da898dbecf179a8fed7243e8cb803295b6b3c36c359ee184f62f378961ee7877c8e2ae02bd8ce8187605cad";
  final String loginIdColumn = "ClassB";
  final String passwordColumn = "ClassE";

  _makePostRequest() async {
    var lLoginId = loginIdController.text.trim();
    var lPassword = passwordController.text.trim();
    if (lLoginId.isEmpty) {
      _outputInfo("入力エラー", "ログインIDを入力してください。");
      return;
    }else if (lPassword.isEmpty) {
      _outputInfo("入力エラー", "パスワードを入力してください。");
      return;
    }else{}
    String url = 'http://' + server+'/api/items/'+sideId+'/get';
    Map<String, String> headers = {"Content-type": "application/json"};
    var pleasanterJson = {"ApiVersion": 1.1, "ApiKey": apiKey, "Offset": 0,
      "View": {"NearCompletionTime": true,"ColumnFilterHash": {loginIdColumn: lLoginId, passwordColumn: lPassword}}};

    Response response = await post(url, headers: headers, body: json.encode(pleasanterJson));
    if (response.statusCode == 200) {
      var dbResult = json.decode(response.body);
      if (dbResult['Response']['TotalCount'] == 1) {
        loginIdController.text = "";
        passwordController.text = "";
        Navigator.of(context).pushNamed('Home');
      }else{
        _outputInfo("", "ログイン失敗");
      }
    }else{
      _outputInfo("", "サーバと接続失敗");
    }
  }

  _outputInfo(String iTitle, String iErrInfo){
    Widget cancelButton = FlatButton(
      child: Text("OK"),
      onPressed:  () {Navigator.of(context).pop();},
    );
    AlertDialog alert = AlertDialog(
      title: Text(iTitle),
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
    loginIdController.dispose();
    passwordController.dispose();
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
                    child: Text('GPSトラッカー（仮）へようこそ', style: TextStyle(fontSize: 14),),
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
                    height: maxHeight / 32,
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
                        onPressed: _makePostRequest,
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Text(
                          'ログイン',
                          style: TextStyle(
                              color:Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                      )
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
                    width: size.width,
                    height: maxHeight / 64 *3,
                    child: GestureDetector(
                      onTap: () {
                        //Navigator.pushNamed(context, "myRoute");
                      },
                      child: Text('ID・パスワードを忘れた方', style: TextStyle(fontSize: 14, color: Colors.blue), textAlign: TextAlign.center,),
                    ),
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
                    width: size.width,
                    height: maxHeight / 64 *3,
                    child: Text('新規ユーザー登録', style: TextStyle(fontSize: 14), textAlign: TextAlign.center,),
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
                          print( kToolbarHeight);
                          Navigator.of(context).pushNamed('Register');
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
