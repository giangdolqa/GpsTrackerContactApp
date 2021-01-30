// 通常情報

class DeviceDBInfo {
  String id; // デバイスID
  String name; // 名称
  String key; // 暗号キー
  String keyDate; // 暗号キー日付
  String keyRule; // 暗号キールール
  String userName; // ユーザー名称
  num state; // 接続状態
  num count; // 設定次数
  String bleId; // BLEID
  String password; // 一時パスワード
  String tekInfo; // TEK/Enin情報
  String rpiInfo; // RPI/AEM情報
  String reportId;
  String reportKey;
  DateTime created = DateTime.now();

  /// Map
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device_id'] = this.id;
    data['name'] = this.name;
    data['key'] = this.key;
    data['key_date'] = this.keyDate;
    data['key_rule'] = this.keyRule;
    data['username'] = this.userName;
    data['state'] = this.state;
    data['setting_count'] = this.count;
    data['ble_id'] = this.bleId;
    data['password'] = this.password;
    data['rpi_aem'] = this.rpiInfo;
    data['tek_enin'] = this.tekInfo;
    data['reportId'] = this.reportId;
    data['reportKey'] = this.reportKey;
    data['created'] = this.created.millisecondsSinceEpoch;
    return data;
  }

  void fromMap(Map<String, dynamic> inputMap) {
    id = inputMap['device_id'];
    name = inputMap['name'];
    key = inputMap['key'];
    keyDate = inputMap['key_date'];
    keyRule = inputMap['key_rule'];
    userName = inputMap['username'];
    state = inputMap['state'];
    count = inputMap['setting_count'];
    bleId = inputMap['ble_id'];
    password = inputMap['password'];
    rpiInfo = inputMap['rpi_aem'];
    tekInfo = inputMap['tek_enin'];
    reportId = inputMap['reportId'];
    reportKey = inputMap['reportKey'];
    created = DateTime.fromMillisecondsSinceEpoch(inputMap['created']);
  }
}
