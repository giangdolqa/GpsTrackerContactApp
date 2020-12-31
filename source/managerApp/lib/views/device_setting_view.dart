import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';

class DeviceSettingView extends StatefulWidget {
  DeviceSettingView({Key key}) : super(key: key);

  @override
  DeviceSettingViewState createState() => DeviceSettingViewState();
}

class DeviceSettingViewState extends State<DeviceSettingView> {
  String deviceId = 'GPS1111';

  bool _isCheck = false;
  bool _flag = false;
  bool _keyVisible = true;
  int _minHumidity = 0;
  int _minInterval = 0;
  int _maxHumidity = 100;
  int _maxInterval = 60;

  DateTime selectedDate = DateTime.now();

  //Controller
  final nameCtrlr = TextEditingController();
  final birthdayCtrlr = TextEditingController();
  final humidityCtrlr = TextEditingController();
  final keyCtrlr = TextEditingController();
  final intervalCtrlr = TextEditingController();
  final codeCtrlr = TextEditingController();

  // FocusNode
  FocusNode _nameFocus = FocusNode();
  FocusNode _humidityFocus = FocusNode();
  FocusNode _keyFocus = FocusNode();
  FocusNode _intervalFocus = FocusNode();
  FocusNode _codeFocus = FocusNode();

  // Validators
  bool _nameVld = false;
  bool _birthdayVld = false;
  bool _humidityVld = false;
  bool _keyVld = false;
  bool _intervalVld = false;
  bool _codeVld = false;

  // GenderVal
  String dropdownValue;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameCtrlr.dispose();
    birthdayCtrlr.dispose();
    humidityCtrlr.dispose();
    keyCtrlr.dispose();
    intervalCtrlr.dispose();
    codeCtrlr.dispose();
    super.dispose();
  }

  void unfocusAll() {
    _nameFocus.unfocus();
    _humidityFocus.unfocus();
    _keyFocus.unfocus();
    _intervalFocus.unfocus();
    _codeFocus.unfocus();
  }

  // Get Gender
  int _GetGender() {
    int rlst = 0;
    if (dropdownValue == '男の子') {
      rlst = 1; // Male
    } else if (dropdownValue == '女の子') {
      rlst = 2; // Female
    } else if (dropdownValue == '答えない') {
      rlst = 3; // Other
    } else {
      rlst = 0; // Unknown
    }
    return rlst;
  }

  Future<void> _selectDate() async {
    unfocusAll();
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate.subtract(new Duration(days: 7300)),
      lastDate: selectedDate,
    );

    if (date == null) return;

    setState(() {
      selectedDate = date;
    });
  }

  void _addHumidity() {
    unfocusAll();
    if (humidityCtrlr.text.isEmpty) {
      humidityCtrlr.text = '0';
    }
    if (int.parse(humidityCtrlr.text) + 1 > _maxHumidity) {
      return;
    } else {
      setState(() {
        humidityCtrlr.text = (int.parse(humidityCtrlr.text) + 1).toString();
      });
    }
  }

  void _subtractHumidity() {
    unfocusAll();
    if (humidityCtrlr.text.isEmpty) {
      humidityCtrlr.text = '0';
    }
    if (int.parse(humidityCtrlr.text) - 1 < _minHumidity) {
      return;
    } else {
      setState(() {
        humidityCtrlr.text = (int.parse(humidityCtrlr.text) - 1).toString();
      });
    }
  }

  void _addInterval() {
    unfocusAll();
    if (intervalCtrlr.text.isEmpty) {
      intervalCtrlr.text = '0';
    }
    if (int.parse(intervalCtrlr.text) + 1 > _maxInterval) {
      return;
    } else {
      setState(() {
        intervalCtrlr.text = (int.parse(intervalCtrlr.text) + 1).toString();
      });
    }
  }

  void _subtractInterval() {
    unfocusAll();
    if (intervalCtrlr.text.isEmpty) {
      intervalCtrlr.text = '0';
    }
    if (int.parse(intervalCtrlr.text) - 1 < _minInterval) {
      return;
    } else {
      setState(() {
        intervalCtrlr.text = (int.parse(intervalCtrlr.text) - 1).toString();
      });
    }
  }

  Future<void> _getCode(BuildContext context) async {
    unfocusAll();
  }

  Future<void> _registerSubmit(BuildContext context) async {
    unfocusAll();
    setState(() {
      nameCtrlr.text.isEmpty ? _nameVld = true : _nameVld = false;
      birthdayCtrlr.text.isEmpty ? _birthdayVld = true : _birthdayVld = false;
      humidityCtrlr.text.isEmpty ? _humidityVld = true : _humidityVld = false;
      keyCtrlr.text.isEmpty ? _keyVld = true : _keyVld = false;
      intervalCtrlr.text.isEmpty ? _intervalVld = true : _intervalVld = false;
      codeCtrlr.text.isEmpty ? _codeVld = true : _codeVld = false;
    });
    // Validate
    if (_nameVld ||
        _birthdayVld ||
        _humidityVld ||
        _keyVld ||
        _intervalVld ||
        _codeVld) {
      // return if input not validated
      return;
    }
    int _gender = _GetGender();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
//      onWillPop: () async {
//        return false;
//      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(deviceId + 'の設定'),
          elevation: 15,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          children: <Widget>[
            // 名前
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      '名前',
                      style: TextStyle(
                        inherit: true,
                        color: Colors.black,
                        fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: TextField(
//                      maxLength: 30,
//                      inputFormatters: [InputFormatUtil.OnlyEnglishAndNumber, LengthLimitingTextInputFormatter(50)],
                      controller: nameCtrlr,
                      focusNode: _nameFocus,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 15.0),
                        border: OutlineInputBorder(),
                        errorText: _nameVld ? '名前を入力してください' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 性別
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      '性別',
                      style: TextStyle(
                        inherit: true,
//                        fontFamily: 'Arial Black',
//                        color: Colors.black,
                        fontSize: 20.0,
//                          wordSpacing: 10,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(left: 15.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26, width: 1),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.elliptical(4, 4),
                            bottom: Radius.elliptical(4, 4)),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: dropdownValue,
                        icon: Icon(Icons.keyboard_arrow_down),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                        onChanged: (newValue) {
                          unfocusAll();
                          setState(() {
                            dropdownValue = newValue;
                          });
                        },
                        underline: Container(color: Colors.transparent),
                        items: <String>[
                          '男の子',
                          '女の子',
                          '答えない',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 生年月日
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      '生年月日',
                      style: TextStyle(
                        inherit: true,
                        color: Colors.black,
                        fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26, width: 1),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.elliptical(4, 4),
                            bottom: Radius.elliptical(4, 4)),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 12.0),
                      child: InkWell(
                        onTap: _selectDate,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // アラート湿度
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      'アラート湿度',
                      style: TextStyle(
                        inherit: true,
                        color: Colors.black,
                        fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: TextField(
//                      maxLength: 30,
//                      inputFormatters: [InputFormatUtil.OnlyEnglishAndNumber, LengthLimitingTextInputFormatter(50)],
                      keyboardType: TextInputType.number,
                      controller: humidityCtrlr,
                      focusNode: _humidityFocus,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 15.0),
                        border: OutlineInputBorder(),
                        errorText: _humidityVld ? 'アラート湿度を入力してください' : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    '%',
                    style: TextStyle(
                      inherit: true,
                      color: Colors.black,
                      fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Container(
                    width: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.elliptical(10, 10),
                          right: Radius.elliptical(0, 0)),
                      color: Colors.grey[500],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _addHumidity();
                      },
                      color: Colors.white,
                      icon: Icon(Icons.arrow_drop_up),
                    ),
                  ),
                  Container(
                    width: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.elliptical(0, 0),
                          right: Radius.elliptical(10, 10)),
                      color: Colors.grey[500],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _subtractHumidity();
                      },
                      color: Colors.white,
                      icon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ],
              ),
            ),
            // キーラベル
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      'キー',
                      style: TextStyle(
                        inherit: true,
                        color: Colors.black,
                        fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // キー入力
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
//                      maxLength: 30,
//                      inputFormatters: [InputFormatUtil.OnlyEnglishAndNumber, LengthLimitingTextInputFormatter(50)],
                      controller: keyCtrlr,
                      focusNode: _keyFocus,
                      obscureText: _keyVisible,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 15.0),
                        border: OutlineInputBorder(),
                        errorText: _nameVld ? '名前を入力してください' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // キーを表示チェックボックス
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    value: _isCheck,
                    onChanged: (bool value) {
                      unfocusAll();
                      setState(() {
                        _isCheck = value;
                        _keyVisible = !value;
                      });
                    },
                  ),
//                  SizedBox(width: 20.0),
                  Container(
                    child: Text(
                      'キーを表示',
                      style: TextStyle(
                        inherit: true,
                        color: Colors.black,
                        fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 送信の間隔
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      '送信の間隔',
                      style: TextStyle(
                        inherit: true,
                        color: Colors.black,
                        fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: TextField(
//                      maxLength: 30,
//                      inputFormatters: [InputFormatUtil.OnlyEnglishAndNumber, LengthLimitingTextInputFormatter(50)],
                      keyboardType: TextInputType.number,
                      focusNode: _intervalFocus,
                      controller: intervalCtrlr,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 15.0),
                        border: OutlineInputBorder(),
                        errorText: _intervalVld ? '送信の間隔を入力してください' : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    '分',
                    style: TextStyle(
                      inherit: true,
                      color: Colors.black,
                      fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Container(
                    width: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.elliptical(10, 10),
                          right: Radius.elliptical(0, 0)),
                      color: Colors.grey[500],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _addInterval();
                      },
                      color: Colors.white,
                      icon: Icon(Icons.arrow_drop_up),
                    ),
                  ),
                  Container(
                    width: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.elliptical(0, 0),
                          right: Radius.elliptical(10, 10)),
                      color: Colors.grey[500],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _subtractInterval();
                      },
                      color: Colors.white,
                      icon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ],
              ),
            ),
            // 記録
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      '記録',
                      style: TextStyle(
                        inherit: true,
                        color: Colors.black,
                        fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Switch(
                    value: _flag,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      unfocusAll();
                      setState(() {
                        _flag = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            // 認証コード
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      '認証コード',
                      style: TextStyle(
                        inherit: true,
                        color: Colors.black,
                        fontSize: 20.0,
//                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: TextField(
//                      maxLength: 30,
//                      inputFormatters: [InputFormatUtil.OnlyEnglishAndNumber, LengthLimitingTextInputFormatter(50)],
                      controller: codeCtrlr,
                      focusNode: _codeFocus,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 15.0),
                        border: OutlineInputBorder(),
                        errorText: _codeVld ? '認証コードを入力してください' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 認証コード取得ボタン
            Container(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'まで',
                    style: TextStyle(
                      inherit: true,
                      color: Colors.black,
                      fontSize: 12.0,
//                        fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  RaisedButton(
                    shape: StadiumBorder(),
                    color: Colors.blue,
                    onPressed: () {
                      _getCode(context);
                    },
//                  disabledColor: Colors.l,
                    child: Text(
                      '認証コード取得',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    elevation: 10,
                  ),
                ],
              ),
            ),
            // OK button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: RaisedButton(
                      shape: StadiumBorder(),
                      color: Colors.blue,
                      onPressed: () {
                        _registerSubmit(context);
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                      elevation: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
