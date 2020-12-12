import 'package:flutter/material.dart';
//import 'package:http/http.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPSトラッカー',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,

        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'GPSトラッカーへようこそ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _checkBox1 = false;

  _makePostRequest() async {
    String url = '';
    Map<String, String> headers = {"Content-type": "application/json"};
    String json = '{';
    //Response response = await post(url, headers: headers, body: json);
    //int statusCode = response.statusCode;
    //String body = response.body;
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
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
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container( // 上部のフロントカメラによる表示しない部分を回避
                  width: size.width,
                  height: maxHeight / 16,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start, // 上記の幅の右端に設置
              children: <Widget>[
                Container( // 左揃え用
                  width: size.width / 32 * 1,
                  height: maxHeight / 16,
                ),
                Container(
                  width: size.width / 32 * 31,
                  height: maxHeight / 16,
                  child: Text('GPSトラッカーへようこそ', style: TextStyle(fontSize: 14),),
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
                    obscureText: !_checkBox1,
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
                        //this.setState((){
                        //  _checkBox1 = true;
                        //});
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
    );
  }
}
