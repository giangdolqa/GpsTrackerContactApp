const request = require('request');
const crypto = require('crypto')
const moment = require("moment");
const mail = require("./mail.js");
const sms = require("./sms.js");

const URL = 'http://ik1-407-35954.vs.sakura.ne.jp/api/';
const API_KEY = 'b112d2d4dc3ccd0c24fd560174a94290b2281810e164d99b2cecc345f9c1ebafa5d691d29f0119768e694599020e7cd969bfa529ba369339773fe758bc044f5d';
const ALGO = 'aes-256-cbc';
const PASSWORD = 'NcVpn_dCAVe#+_*';
const SALT = 'v4CYLWpU#QZM$&L';
const TemporaryPasswordFile = 'TemporaryPassword.txt';

//ユーザ情報作成
exports.create_user = function(res, req){
	request.post({
		uri: URL + 'items/2/create',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			ClassHash: {
				ClassA: req.body.Name,				// 名前
				ClassB: req.body.ZipCode,			// 郵便番号
				ClassC: req.body.Prefectures,		// 都道府県
				ClassD: req.body.Address,			// 住所
				ClassE: req.body.TelephoneNumber,	// 電話番号
				ClassF: req.body.EmailAddress,		// メールアドレス
				ClassG: req.body.LoginID,			// ログインID
				ClassH: encryptBase64(req.body.Password)	// パスワード
			},
			CheckHash: {
				CheckA: false
			}
		})
	}, (error, response, body) => {
		if (!error && response.statusCode === 200) {
			res.sendStatus(200);
		}
		else{
			res.send(response);
		}
	});
}

//ユーザ情報変更
exports.update_user = function(res, req){
	request.post({
		uri: URL + 'items/2/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassF: req.EmailAddress		// メールアドレス
				}
			}
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
							ClassA: req.body.Name,				// 名前
							ClassB: req.body.ZipCode,			// 郵便番号
							ClassC: req.body.Prefectures,		// 都道府県
							ClassD: req.body.Address,			// 住所
							ClassE: req.body.TelephoneNumber,	// 電話番号
							ClassF: req.body.EmailAddress,		// メールアドレス
							ClassG: req.body.LoginID,			// ログインID
							ClassH: encryptBase64(req.body.Password)	// パスワード
						},
						CheckHash: {
							CheckA: false
						}
					})
				}, (error, response, body) => {
					if (!error && response.statusCode === 200) {
						res.sendStatus(200);
					}
					else{
						res.send(response);
					}
				});
			}
		}
		else{
			res.json({Error, Message : response.Message }, response.statusCode);
		}
	});
}

//ユーザ情報取得
exports.get_user = function(res, req){
	request.post({
		uri: URL + 'items/2/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassF: req.EmailAddress		// メールアドレス
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.Data.length > 0){
				var data = bodyJson.Response.Data[0];
				let resData = {
					Name:			data.ClassHash.ClassA,	// 名前
					ZipCode:		data.ClassHash.ClassB,	// 郵便番号
					Prefectures:	data.ClassHash.ClassC,	// 都道府県
					Address:		data.ClassHash.ClassD,	// 住所
					TelephoneNumber:data.ClassHash.ClassE,	// 電話番号
					EmailAddress:	data.ClassHash.ClassF,	// メールアドレス
					LoginID:		data.ClassHash.ClassG,	// ログインID
					Password:		decryptBase64(data.ClassHash.ClassH),	// パスワード
					Authentication:	data.CheckHash.CheckA
				};
				res.json(resData);
			}
		}
		else{
			res.json({Error, Message : response.Message }, response.statusCode);
		}
	});
}

//ユーザ情報削除
exports.delete_user = function(res, req){
	request.post({
		uri: URL + 'items/2/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassF: req.EmailAddress		// メールアドレス
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.Data.length > 0){
				var data = bodyJson.Response.Data[0];
				request.post({
					uri: URL + 'items/' + data.ResultId +'/delete',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY
					})
				}, (error, response, body) => {
					if (!error && response.statusCode === 200) {
						res.sendStatus(200);
					}
					else{
						res.send(response);
					}
				});
			}
		}
		else{
			res.json({Error, Message : response.Message }, response.statusCode);
		}
	});
}

//認証コード発行
exports.request_auth = function(res, req){
	request.post({
		uri: URL + 'items/2/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassG: req.body.LoginID			// ログインID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.Data.length > 0){
				var data = bodyJson.Response.Data[0];
				var mailCode = generatePassword();
				var smsCode = generatePassword();
				request.post({
					uri: URL + 'items/' + data.ResultId +'/update',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						ClassHash: {
							ClassI: mailCode,
							ClassJ: smsCode
						},
						DateHash: {
							DateA: moment().format("YYYY-MM-DDTHH:mm:ss")
						},
						CheckHash: {
							CheckA: false
						}
					})
				}, (error, response, body) => {
					if (!error && response.statusCode === 200) {
						//認証コードを送信する
						mail.send(data.ClassHash.ClassF, mailCode);
						sms.send(data.ClassHash.ClassE, smsCode);
						res.sendStatus(200);
					}
					else{
						res.send(response);
					}
				});
			}
		}
		else{
			res.json({Error, Message : response.Message }, response.statusCode);
		}
	});
}

//認証コード確認
exports.verify_auth = function(res, req){
	request.post({
		uri: URL + 'items/2/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassG: req.body.LoginID			// ログインID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.Data.length > 0){
				var data = bodyJson.Response.Data[0];
				var limit = new Date(data.DateHash.DateA);
				limit.setMinutes(limit.getMinutes() + 30);
				if(limit < new Date()){
					res.json({Error, Message : 'Authentication code expired' }, 400);
				}
				var mailCode = data.ClassHash.ClassF;
				var smsCode = data.ClassHash.ClassE;
				if(mailCode !== req.mailCode || smsCode !== req.smsCode){
					res.json({Error, Message : 'Authentication code mismatch' }, 401);
				}
				request.post({
					uri: URL + 'items/' + data.ResultId +'/update',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						CheckHash: {
							CheckA: true
						}
					})
				}, (error, response, body) => {
					if (!error && response.statusCode === 200) {
						request.post({
							uri: URL + 'items/14/get',
							headers: { "Content-type": "application/json;charset=utf-8" },
							body: JSON.stringify({
								ApiVersion: 1.1,
								ApiKey: API_KEY,
							})
						}, function(error, response, body){
							if (!error && response.statusCode === 200) {
								const bodyJson = JSON.parse(body);
								if (bodyJson.Response.Data.length > 0){
									var data = bodyJson.Response.Data[0];
									let resData = {
										TemporaryPassword:data.ClassHash.ClassA,	// パスワード
									};
									res.json(resData);
								}else{
									res.json({Error, Message : 'Not Temporary Password' }, 402);
								}
							}
							else{
								res.json({Error, Message : response.Message }, response.statusCode);
							}
						});
					}
					else{
						res.send(response);
					}
				});
			}
		}
		else{
			res.json({Error, Message : response.Message }, response.statusCode);
		}
	});
}

// パスワード生成
var generatePassword = function(length = 6){
	let password_base = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
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
