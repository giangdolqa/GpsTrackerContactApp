// ローカル保存
import 'package:shared_preferences/shared_preferences.dart';

SharedPreUtil spUtil = new SharedPreUtil();

// Util for shared preferences
class SharedPreUtil {
  Future<Object> sharedGetData(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(key);
  }

  sharedDeleteData(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(key);
  }

  Future SavePhoneNum(String inputPhoneNum) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool bRslt = await sharedPreferences.setString("PhoneNum", inputPhoneNum);
//    //print("Save phoneNum : [" + inputPhoneNum+ "] Result:" + bRslt.toString());
  }

  Future GetPhoneNum() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("PhoneNum");
  }

  Future SaveTEK(String inputTEK) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("TEK", inputTEK);
  }

  Future GetTEK() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("TEK");
  }

  // 128bit token
  Future SaveToken(String inputToken) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("Token", inputToken);
  }

  // 128bit token
  Future GetToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("Token");
  }

  // Server FCM token
  Future SaveSeverFCMToken(String inputToken) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("ServerFCMToken", inputToken);
  }

  // Server FCM token
  Future GetServerFCMToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("ServerFCMToken");
  }

  Future SaveUsername(String inputPhoneNum) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool bRslt = await sharedPreferences.setString("UserName", inputPhoneNum);
  }

  Future GetUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("UserName");
  }
  Future SavePassword(String inputPhoneNum) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool bRslt = await sharedPreferences.setString("Password", inputPhoneNum);
  }

  Future GetPassword() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("Password");
  }
}
