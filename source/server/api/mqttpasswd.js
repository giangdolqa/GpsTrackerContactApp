const request = require('request');
const crypto = require('crypto')
const util    = require('util');
const bodyParser = require('body-parser')
const fs = require('fs');

const USER_TABLE 			= '2'
const DEVICE_TABLE			= '4'
const SCHOOL_TABLE			= '8'
const TEMPPASSWORD_TABLE	= '14'

const URL = 'http://ik1-407-35954.vs.sakura.ne.jp/api/';
const API_KEY = 'b112d2d4dc3ccd0c24fd560174a94290b2281810e164d99b2cecc345f9c1ebafa5d691d29f0119768e694599020e7cd969bfa529ba369339773fe758bc044f5d';
const ALGO = 'aes-256-cbc';
const PASSWORD = 'NcVpn_dCAVe#+_*';
const SALT = 'v4CYLWpU#QZM$&L';

const passwd_file = '/etc/mosquitto/password.txt';
//const passwd_file = '/home/gpstracker/password.txt';

var passwdArray = [];

// パスワード生成
var generatePassword = function(length = 20){
	let password_base = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&()=~|@[];:+-*<>?_>.,\'';
	let password = '';
	for (let i = 0; i < length; i++) {
		password += password_base.charAt(Math.floor(Math.random() * password_base.length));
	}
	return password;
}

// 暗号化
var encryptBase64 = function(data) {
	const key = crypto.scryptSync(PASSWORD, SALT, 32);		// 鍵を生成
	const iv = crypto.randomBytes(16)						// IV を生成
	const cipher = crypto.createCipheriv(ALGO, key, iv)		// 暗号器を生成
	const encryptedData = cipher.update(Buffer.from(data))	// dataをバイナリにして暗号化
	// 末端処理 ＆ 先頭にivを付与し、バイナリをbase64(文字列)にして返す
	return Buffer.concat([iv, encryptedData, cipher.final()]).toString('base64');
}

// 複合化
var decryptBase64 = function(data) {
	const key = crypto.scryptSync(PASSWORD, SALT, 32);		// 鍵を生成
	const buff = Buffer.from(data, 'base64');				// 暗号化文字列をバイナリに変換
	const iv = buff.slice(0, 16);							// iv値である、先頭16byteを取り出す
	const encryptedData = buff.slice(16);					// iv値以降の、暗号化データを取り出す
	const decipher = crypto.createDecipheriv(ALGO, key, iv);// 復号器を生成
	const decryptData = decipher.update(encryptedData);		// 暗号化データを復号化
	// 末端処理 ＆ バイナリを文字列に戻す
	return Buffer.concat([decryptData, decipher.final()]).toString('utf8');
}

//一時パスワード取得
const get_temporary_passwd = new Promise((resolve, reject) => {
	var passwd = generatePassword();
	passwdArray.push('temporary:' + passwd);
	request.post({
		uri: URL + 'items/' + TEMPPASSWORD_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.Data.length > 0){
				var data = bodyJson.Response.Data[0];
				request.post({
					uri: URL + 'items/' + data.ResultId +'/update',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						ClassHash: {
							ClassA: passwd
						}
					})
				});
			}
		}
	});
	resolve(1);
})

//ユーザ情報パスワード取得
const get_user_passwd = new Promise((resolve, reject) => {
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					CheckA: true
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			bodyJson.Response.Data.forEach(data => {
				passwdArray.push(data.ClassHash.ClassG + ':' + decryptBase64(data.ClassHash.ClassH));
			});
			resolve(1);
		}
	});
})

//デバイス情報パスワード取得
const get_device_passwd = new Promise((resolve, reject) => {
	request.post({
		uri: URL + 'items/' + DEVICE_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			bodyJson.Response.Data.forEach(data => {
				passwdArray.push(data.ClassHash.ClassB + ':' + decryptBase64(data.ClassHash.ClassC));
			});
			resolve(1);
		}
	});
})

//学校情報パスワード取得
const get_school_passwd = new Promise((resolve, reject) => {
	request.post({
		uri: URL + 'items/' + SCHOOL_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			bodyJson.Response.Data.forEach(data => {
				passwdArray.push(data.ClassHash.ClassA + ':' + decryptBase64(data.ClassHash.ClassB));
			});
			resolve(1);
		}
	});
})

//一時パスワード取得
get_temporary_passwd.then((value) => {
	//ユーザ情報パスワード取得
	get_user_passwd.then((value) => {
		//デバイス情報パスワード取得
		get_device_passwd.then((value) => {
			//学校情報パスワード取得
			get_school_passwd.then((value) => {
				//パスワード出力
				var passwd_text = '';
				var ret_code = '';
				passwdArray.forEach(passwd => {
					passwd_text += ret_code + passwd;
					ret_code = '\n';
				});
				fs.writeFile(passwd_file, passwd_text, function(err) {})
			});
		});
	});
});
