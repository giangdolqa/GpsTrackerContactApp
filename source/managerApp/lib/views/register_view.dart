import 'dart:ui';
import 'package:marmo/views/twice_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';

class RegisterView extends StatefulWidget {
  @override
  _Register createState() => _Register();
}

class _Register extends State<RegisterView> {
  var _checkBox1 = false;
  final usernameController = TextEditingController();
  final addressController = TextEditingController();
  final zipCodeController = TextEditingController();
  final mailController = TextEditingController();
  final phoneController = TextEditingController();
  final loginIdController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  List<String> _items = ["00  ",     "01北海道", "02青森県", "03岩手県", "04宮城県",
                         "05秋田県", "06山形県", "07福島県", "08茨城県", "09栃木県",
                         "10群馬県", "11埼玉県", "12千葉県", "13東京都", "14神奈川県",
                         "15新潟県", "16富山県", "17石川県", "18福井県", "19山梨県",
                         "20長野県", "21岐阜県", "22静岡県", "23愛知県", "24三重県",
                         "25滋賀県", "26京都府", "27大阪府", "28兵庫県", "29奈良県",
                         "30和歌山県", "31鳥取県", "32島根県", "33岡山県", "34広島県",
                         "35山口県", "36徳島県", "37香川県", "38愛媛県", "39高知県",
                         "40福岡県", "41佐賀県", "42長崎県", "43熊本県", "44大分県",
                         "45宮崎県", "46鹿児島県", "47沖縄県"];
  String _selectedItem = "00";
  String _radVal = "";

  _registerUserInfo(String iUsername, String iZipCode, String iAddress, String iEmail, String iPhone, String iLoginId, String iPassword, String iRePassword) async {
    if (iUsername.trim().isEmpty) {
      _outputEmptyInfo("入力エラー", "お名前を入力してください。");
      return;
    }else if (iZipCode.trim().isEmpty) {
      _outputEmptyInfo("入力エラー", "郵便番号を入力してください。");
      return;
    }else if (_selectedItem == "00") {
      _outputEmptyInfo("入力エラー", "都道府県を選択してください。");
      return;
    }else if (iAddress.trim().isEmpty) {
      _outputEmptyInfo("入力エラー", "住所を入力してください。");
      return;
    }else if (iPhone.trim().isEmpty) {
      _outputEmptyInfo("入力エラー", "電話番号を入力してください。");
      return;
    }else if (iEmail.trim().isEmpty) {
      _outputEmptyInfo("入力エラー", "メールアドレスを入力してください。");
      return;
    }else if (iLoginId.trim().isEmpty) {
      _outputEmptyInfo("入力エラー", "ログインIDを入力してください。");
      return;
    }else if (iPassword.trim().isEmpty) {
      _outputEmptyInfo("入力エラー", "パスワードを入力してください。");
      return;
    }else if (iRePassword.trim().isEmpty) {
      _outputEmptyInfo("入力エラー", "パスワードの確認を入力してください。");
      return;
    }else if (_radVal == "") {
      _outputEmptyInfo("入力エラー", "組織を選択してください。");
      return;
    }else if(RegExp(r"^[0-9]{3}-[0-9]{4}$").hasMatch(iZipCode.trim()) == false){
      _outputEmptyInfo("入力エラー", "郵便番号が不正です。");
      return;
    }else if(RegExp(r"^[a-zA-Z0-9_.+-]+@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$").hasMatch(iEmail.trim()) == false){
      _outputEmptyInfo("入力エラー", "メールアドレスが不正です。");
      return;
    }else if(RegExp(r"^0\d{1,4}-\d{1,4}-\d{4}$").hasMatch(iPhone.trim()) == false){
      _outputEmptyInfo("入力エラー", "電話番号に半角数字「-」を正しく入力ください。");
      return;
    }else if(RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(iLoginId.trim()) == false){
      _outputEmptyInfo("入力エラー", "ログインIDに半角英数アンダーバー以外があります。");
      return;
    }else if(RegExp(r"^[a-zA-Z0-9!-/:-@¥[-`{-~]+$").hasMatch(iPassword.trim()) == false){
      _outputEmptyInfo("入力エラー", "パスワードに半角英数記号以外があります。");
      return;
    }else if(iPassword.trim()!=iRePassword.trim()){
      _outputEmptyInfo("入力エラー", "2回入力したパスワードが不一致です。");
      return;
    }else{}

    final String url = "http://ik1-407-35954.vs.sakura.ne.jp:3000/api/v1/";
    Map<String, String> headers = {"Content-type": "application/json"};

    var pleasanterJson = {"Name":iUsername.trim().toString(),
    "ZipCode": iZipCode.trim().toString(),
    "Prefectures":_selectedItem,
    "Address":iAddress.trim().toString(),
    "TelephoneNumber":iPhone.trim().toString(),
    "EmailAddress":iEmail.trim().toString(),
    "LoginID":iLoginId.trim().toString(),
    "Password":iPassword.trim().toString(),
    "Type":_radVal};

    Response response = await post(url + "user", headers: headers, body: json.encode(pleasanterJson));

    if (response.statusCode == 200) {
      Response response = await patch(url + "auth/request", headers: headers, body: json.encode(
          { "LoginID":iUsername.trim().toString()}));
      print("42342342" + response.statusCode.toString());
      Navigator.push(
          this.context,
          MaterialPageRoute(builder: (context) => TwiceCheckView(loginId: iLoginId.trim().toString()))
      );
    }else{
      _outputEmptyInfo("登録異常", json.decode(response.body)['Message']);
    }
  }

  _outputEmptyInfo(String iTitle, String iErrInfo){
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
  void _onChanged(String value) {
    setState(() {
      _radVal = value;
    });
  }
  @override
  // widgetの破棄時にコントローラも破棄する
  void dispose() {
    usernameController.dispose();
    addressController.dispose();
    zipCodeController.dispose();
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
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: size.width / 32 * 10,
                        height: maxHeight / 32,
                        child: Text('郵便番号', style: TextStyle(fontSize: 14),),
                      ),
                      Container(
                        width: size.width / 32 * 10,
                        height: maxHeight / 16,
                        child: TextField(
                          controller: zipCodeController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "000-0000",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: size.width / 32 * 1,
                    height: maxHeight / 32,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: size.width / 32 * 10,
                        height: maxHeight / 32,
                        child: Text('都道府県', style: TextStyle(fontSize: 14),),
                      ),
                      Container(
                        width: size.width / 32 * 10,
                        height: maxHeight / 16,
                        child: DropdownButton<String>(
                          iconDisabledColor:Colors.blue,
                          value: _selectedItem,
                          onChanged: (String newValue) {
                            setState(() {_selectedItem = newValue;});
                          },
                          selectedItemBuilder: (context) {
                            return _items.map((String item) {
                              return Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child:Text(
                                    item.substring(2,item.length),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black),
                                  ));
                            }).toList();
                          },
                          items: _items.map((String item) {
                            return DropdownMenuItem(
                              value: item.substring(0, 2),
                              child: Container(
                                child: Text(
                                  item.substring(2,item.length),
                                  textAlign: TextAlign.center,
                                  style: item == _selectedItem
                                      ? TextStyle(fontWeight: FontWeight.bold,)
                                      : TextStyle(fontWeight: FontWeight.normal),

                                ),),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
                    child: Text('住所', style: TextStyle(fontSize: 14),),
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
                      controller: addressController,
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
                    Container( // 左揃え用
                      width: size.width / 32 * 1,
                      height: maxHeight / 32,
                    ),
                    Radio(
                      activeColor: Colors.blueAccent,
                      value: "学校",
                      groupValue: _radVal,
                      onChanged: _onChanged,
                    )
                    ,
                    Text('学校'),
                    Container(
                      width: size.width / 32 * 1,
                      height: maxHeight / 16,
                    ),
                    Radio(
                      activeColor: Colors.blueAccent,
                      value: "会社",
                      groupValue: _radVal,
                      onChanged: _onChanged,
                    ),
                    Text('会社'),
                    Container(
                      width: size.width / 32 * 1,
                      height: maxHeight / 16,
                    ),
                    Radio(
                      activeColor: Colors.blueAccent,
                      value: "なし",
                      groupValue: _radVal,
                      onChanged: _onChanged,
                    ),
                    Text('なし'),
                  ]
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
                            zipCodeController.text,
                            addressController.text,
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