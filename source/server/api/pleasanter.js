const request = require('request');
const crypto = require('crypto')
const moment = require("moment");
const hkdf = require('@ctrlpanel/hkdf')
const utf8 = require('utf8');
const mail = require("./mail.js");
const sms = require("./sms-clickatell.js");

const URL = 'http://ik1-407-35954.vs.sakura.ne.jp/api/';
const API_KEY = 'b112d2d4dc3ccd0c24fd560174a94290b2281810e164d99b2cecc345f9c1ebafa5d691d29f0119768e694599020e7cd969bfa529ba369339773fe758bc044f5d';
const ALGO = 'aes-256-cbc';
const PASSWORD = 'NcVpn_dCAVe#+_*';
const SALT = 'v4CYLWpU#QZM$&L';

const USER_TABLE 			= '2'
const DEVICE_TABLE			= '4'
const AUTH_TABLE			= '7'
const SCHOOL_TABLE			= '8'
const CONTACT_TABLE			= '9'
const TEMPPASSWORD_TABLE	= '14'
const CONTACT_COUNT_TABLE	= '17'
const MESSAGE_SEND_TABLE	= '28'

//ユーザ情報登録
exports.create_user = function(res, req){
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/create',
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
			res.status(response.statusCode).send(response.body);
		}
	});
}

//ユーザ情報変更
exports.update_user = function(res, req){
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassG: req.body.LoginID	// ログインID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassG !== req.body.LoginID)
					return;
				count++;
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
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//ユーザ情報取得
exports.get_user = function(res, req){
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassF: req.body.EmailAddress	// メールアドレス
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassF !== req.body.EmailAddress)
					return;
				count++;
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
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//ユーザ情報削除
exports.delete_user = function(res, req){
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassG: req.body.LoginID		// ログインID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassG !== req.body.LoginID)
					return;
				count++;
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
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//認証コード発行
exports.request_auth = function(res, req){
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassG: req.body.LoginID	// ログインID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassG !== req.body.LoginID)
					return;
				count++;
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
						var mailSend = false;
						var smsSend = false;
						request.post({
							uri: URL + 'items/' + MESSAGE_SEND_TABLE + '/get',
							headers: { "Content-type": "application/json;charset=utf-8" },
							body: JSON.stringify({
								ApiVersion: 1.1,
								ApiKey: API_KEY
							})
						}, function(error, response, body){
							if (!error && response.statusCode === 200) {
								const bodyJson = JSON.parse(body);
								if (bodyJson.Response.Data.length > 0){
									var willsend = bodyJson.Response.Data[0];
									mailSend = willsend.CheckHash.CheckA;
									smsSend = willsend.CheckHash.CheckB;
								}
							}
							//認証コードを送信する
							mail.send(data.ClassHash.ClassF, mailCode, mailSend);
							sms.send(data.ClassHash.ClassE, smsCode, smsSend);
							res.sendStatus(200);
						});
					}
					else{
						res.send(response);
					}
				});
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//認証コード確認
exports.verify_auth = function(res, req){
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassG: req.body.LoginID	// ログインID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassG !== req.body.LoginID)
					return;
				count++;
				var limit = new Date(data.DateHash.DateA);
				limit.setMinutes(limit.getMinutes() + 30);
				if(limit < new Date()){
					res.statusCode = 401;
					res.json({Error, Message : 'Authentication code expired' });
					return;
				}
				var mailCode = data.ClassHash.ClassI;
				var smsCode = data.ClassHash.ClassJ;
				if(mailCode !== req.body.MailCode || smsCode !== req.body.SmsCode){
					res.statusCode = 402;
					res.json({Error, Message : 'Authentication code mismatch' });
					return;
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
						TemporaryPassword(res);
					}
					else{
						res.send(response);
					}
				});
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'LoginID mismatch' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}


//SMS認証コード発行
exports.request_auth_sms = function(res, req){
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassG: req.body.LoginID	// ログインID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassG !== req.body.LoginID)
					return;
				count++;
				var smsCode = generatePassword();
				request.post({
					uri: URL + 'items/' + data.ResultId +'/update',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						ClassHash: {
							ClassJ: smsCode
						},
						DateHash: {
							DateA: moment().format("YYYY-MM-DDTHH:mm:ss")
						}
					})
				}, (error, response, body) => {
					if (!error && response.statusCode === 200) {
						var smsSend = false;
						request.post({
							uri: URL + 'items/' + MESSAGE_SEND_TABLE + '/get',
							headers: { "Content-type": "application/json;charset=utf-8" },
							body: JSON.stringify({
								ApiVersion: 1.1,
								ApiKey: API_KEY
							})
						}, function(error, response, body){
							if (!error && response.statusCode === 200) {
								const bodyJson = JSON.parse(body);
								if (bodyJson.Response.Data.length > 0){
									var willsend = bodyJson.Response.Data[0];
									smsSend = willsend.CheckHash.CheckB;
								}
							}
							//認証コードを送信する
							sms.send(data.ClassHash.ClassE, smsCode, smsSend);
							res.sendStatus(200);
						});
					}
					else{
						res.send(response);
					}
				});
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//SMS認証コード確認
exports.verify_auth_sms = function(res, req){
	request.post({
		uri: URL + 'items/' + USER_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassG: req.body.LoginID	// ログインID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassG !== req.body.LoginID)
					return;
				count++;
				var limit = new Date(data.DateHash.DateA);
				limit.setMinutes(limit.getMinutes() + 30);
				if(limit < new Date()){
					res.statusCode = 401;
					res.json({Error, Message : 'Authentication code expired' });
					return;
				}
				var smsCode = data.ClassHash.ClassJ;
				if(smsCode === req.body.SmsCode){
					res.sendStatus(200);
					return;
				}
				else {
					res.statusCode = 402;
					res.json({Error, Message : 'Authentication code mismatch' });
					return;
				}
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'LoginID mismatch' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//デバイス情報登録
exports.create_device = function(res, req){
	request.post({
		uri: URL + 'items/' + DEVICE_TABLE + '/create',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			ClassHash: {
				ClassA: req.body.ID,				// ID
				ClassB: req.body.LoginID,			// ログインID
				ClassC: encryptBase64(req.body.Key)	// キー
			},
			CheckHash: {
				CheckA: false
			}
		})
	}, (error, response, body) => {
		if (!error && response.statusCode === 200) {
			TemporaryPassword(res);
		}
		else{
			res.status(response.statusCode).send(response.body);
		}
	});
}

//デバイス情報変更
exports.update_device = function(res, req){
	request.post({
		uri: URL + 'items/' + DEVICE_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassA: req.body.ID		// ID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassA !== req.body.ID)
					return;
				count++;
				request.post({
					uri: URL + 'items/' + data.ResultId +'/update',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						ClassHash: {
							ClassA: req.body.ID,				// ID
							ClassB: req.body.LoginID,			// ログインID
							ClassC: encryptBase64(req.body.Key)	// キー
						}
					})
				}, (error, response, body) => {
					if (!error && response.statusCode === 200) {
						TemporaryPassword(res);
					}
					else{
						res.send(response);
					}
				});
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//デバイス情報取得
exports.get_device = function(res, req){
	request.post({
		uri: URL + 'items/' + DEVICE_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassA: req.body.ID		// ID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassA !== req.body.ID)
					return;
				count++;
				let resData = {
					ID:			data.ClassHash.ClassA,	// ID
					LoginID:	data.ClassHash.ClassB,	// ログインID
					Key:		decryptBase64(data.ClassHash.ClassC)	// キー
				};
				res.json(resData);
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//デバイス情報削除
exports.delete_device = function(res, req){
	request.post({
		uri: URL + 'items/' + DEVICE_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassA: req.body.ID		// ID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassA !== req.body.ID)
					return;
				count++;
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
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//認証コード登録
exports.create_device_code = function(res, req){
	request.post({
		uri: URL + 'items/' + AUTH_TABLE + '/create',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			ClassHash: {
				ClassA: req.body.AuthCode			// 認証コード
			},
			NumHash: {
				NumA: req.body.ValidDays			// 日数
			}
		})
	}, (error, response, body) => {
		if (!error && response.statusCode === 200) {
			res.sendStatus(200);
		}
		else{
			res.status(response.statusCode).send(response.body);
		}
	});
}

//認証コード適用
exports.apply_device_code = function(res, req){
	request.post({
		uri: URL + 'items/' + DEVICE_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassD: req.body.AuthCode	// 認証コード
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassA !== req.body.ID && data.ClassHash.ClassD === req.body.AuthCode){
					res.statusCode = 401;
					res.json({Error, Message : 'This authorization code is used.' });
					return;
				}
			});
			request.post({
				uri: URL + 'items/' + DEVICE_TABLE + '/get',
				headers: { "Content-type": "application/json;charset=utf-8" },
				body: JSON.stringify({
					ApiVersion: 1.1,
					ApiKey: API_KEY,
					Offset: 0,
					View: {
						ColumnFilterHash: {
							ClassA: req.body.ID		// ID
						}
					}
				})
			}, function(error, response, body){
				if (!error && response.statusCode === 200) {
					const bodyJson = JSON.parse(body);
					if (bodyJson.Response.TotalCount <= 0){
						res.statusCode = 400;
						res.json({Error, Message : 'Not record' });
						return;
					}
					var count = 0;
					bodyJson.Response.Data.forEach(data => {
						if(data.ClassHash.ClassA !== req.body.ID)
							return;
						count++;
						var validDays = 0;	//残り日数
						if(data.ClassHash.ClassD !== "" && data.ClassHash.ClassD !== req.body.AuthCode){
							//古い認証コードテーブルの残り日数を取り出す
							request.post({
								uri: URL + 'items/' + AUTH_TABLE + '/get',
								headers: { "Content-type": "application/json;charset=utf-8" },
								body: JSON.stringify({
									ApiVersion: 1.1,
									ApiKey: API_KEY,
									Offset: 0,
									View: {
										ColumnFilterHash: {
											ClassA: data.ClassHash.ClassD,	// 認証コード
											CheckA: false		// 休止中でない
										}
									}
								})
							}, function(error, response, body){
								if (!error && response.statusCode === 200) {
									const bodyJson = JSON.parse(body);
									if (bodyJson.Response.Data.length > 0){
										var dataAuth = bodyJson.Response.Data[0];
										validDays = dataAuth.NumHash.NumA;
										request.post({
											uri: URL + 'items/' + data.ResultId +'/update',
											headers: { "Content-type": "application/json;charset=utf-8" },
											body: JSON.stringify({
												ApiVersion: 1.1,
												ApiKey: API_KEY,
												NumHash: {
													NumA: 0		// 残り日数を0に
												}
											})
										});
										//新しい認証コードテーブルの残り日数を取り出す
										request.post({
											uri: URL + 'items/' + AUTH_TABLE + '/get',
											headers: { "Content-type": "application/json;charset=utf-8" },
											body: JSON.stringify({
												ApiVersion: 1.1,
												ApiKey: API_KEY,
												Offset: 0,
												View: {
													ColumnFilterHash: {
														ClassA: req.body.AuthCode,	// 認証コード
														CheckA: false		// 休止中でない
													}
												}
											})
										}, function(error, response, body){
											if (!error && response.statusCode === 200) {
												const bodyJson = JSON.parse(body);
												if (bodyJson.Response.Data.length > 0){
													var dataAuth = bodyJson.Response.Data[0];
													validDays += dataAuth.NumHash.NumA;
													request.post({
														uri: URL + 'items/' + data.ResultId +'/update',
														headers: { "Content-type": "application/json;charset=utf-8" },
														body: JSON.stringify({
															ApiVersion: 1.1,
															ApiKey: API_KEY,
															NumHash: {
																NumA: validDays		// 残り日数をセット
															}
														})
													});
													//新しい認証コードテーブルの残り日数を取り出す
													let resData = {
														AuthCode: req.body.AuthCode,	// 認証コード
														ValidDays: validDays			// 残り日数
													};
													res.json(resData);

													//認証コードをセットする
													request.post({
														uri: URL + 'items/' + data.ResultId +'/update',
														headers: { "Content-type": "application/json;charset=utf-8" },
														body: JSON.stringify({
															ApiVersion: 1.1,
															ApiKey: API_KEY,
															ClassHash: {
																ClassD: req.body.AuthCode	// 認証コード
															}
														})
													});
												}
											}
											else{
												res.statusCode = response.statusCode;
												res.json({Error, Message : response.Message });
											}
										});
									}
								}
							});
						}
						else {
							//新しい認証コードテーブルの残り日数を取り出す
							request.post({
								uri: URL + 'items/' + AUTH_TABLE + '/get',
								headers: { "Content-type": "application/json;charset=utf-8" },
								body: JSON.stringify({
									ApiVersion: 1.1,
									ApiKey: API_KEY,
									Offset: 0,
									View: {
										ColumnFilterHash: {
											ClassA: req.body.AuthCode,	// 認証コード
											CheckA: false		// 休止中でない
										}
									}
								})
							}, function(error, response, body){
								if (!error && response.statusCode === 200) {
									const bodyJson = JSON.parse(body);
									if (bodyJson.Response.Data.length > 0){
										var dataAuth = bodyJson.Response.Data[0];
										//新しい認証コードテーブルの残り日数を取り出す
										let resData = {
											AuthCode: req.body.AuthCode,		// 認証コード
											ValidDays: dataAuth.NumHash.NumA	// 残り日数
										};
										res.json(resData);

										//認証コードをセットする
										request.post({
											uri: URL + 'items/' + data.ResultId +'/update',
											headers: { "Content-type": "application/json;charset=utf-8" },
											body: JSON.stringify({
												ApiVersion: 1.1,
												ApiKey: API_KEY,
												ClassHash: {
													ClassD: req.body.AuthCode	// 認証コード
												}
											})
										});
									}
								}
								else{
									res.statusCode = response.statusCode;
									res.json({Error, Message : response.Message });
								}
							});
						}
					});
					if(!count){
						res.statusCode = 400;
						res.json({Error, Message : 'Not record' });
						return;
					}
				}
				else{
					res.statusCode = response.statusCode;
					res.json({Error, Message : response.Message });
				}
			});
		}
	});
}

//学校情報登録
exports.create_school = function(res, req){
	request.post({
		uri: URL + 'items/' + SCHOOL_TABLE + '/create',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			ClassHash: {
				ClassA: req.body.ID,				// 学校ID
				ClassB: encryptBase64(req.body.Key)	// キー
			},
			CheckHash: {
				CheckA: false
			}
		})
	}, (error, response, body) => {
		if (!error && response.statusCode === 200) {
			TemporaryPassword(res);
		}
		else{
			res.status(response.statusCode).send(response.body);
		}
	});
}

//学校情報変更
exports.update_school = function(res, req){
	request.post({
		uri: URL + 'items/' + SCHOOL_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassA: req.body.ID		// 学校ID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassA !== req.body.ID)
					return;
				count++;
				request.post({
					uri: URL + 'items/' + data.ResultId +'/update',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						ClassHash: {
							ClassA: req.body.ID,				// 学校ID
							ClassB: encryptBase64(req.body.Key)	// キー
						}
					})
				}, (error, response, body) => {
					if (!error && response.statusCode === 200) {
						TemporaryPassword(res);
					}
					else{
						res.send(response);
					}
				});
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//学校情報取得
exports.get_school = function(res, req){
	request.post({
		uri: URL + 'items/' + SCHOOL_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassA: req.body.ID		// 学校ID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				if(data.ClassHash.ClassA !== req.body.ID)
					return;
				count++;
				let resData = {
					ID:			data.ClassHash.ClassA,	// 学校ID
					Key:		decryptBase64(data.ClassHash.ClassB)	// キー
				};
				res.json(resData);
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//学校情報削除
exports.delete_school = function(res, req){
	request.post({
		uri: URL + 'items/' + SCHOOL_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassA: req.ID				// 学校ID
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.TotalCount <= 0){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
			var count = 0;
			bodyJson.Response.Data.forEach(data => {
				count++;
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
			});
			if(!count){
				res.statusCode = 400;
				res.json({Error, Message : 'Not record' });
				return;
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//陽性登録
exports.create_positive = function(res, req){
	req.body.data.forEach(data => {
		data.ENIN.forEach(ENIN => {
			CalcRPI(data.TEK, parseInt(ENIN, 16)).then(RPI => {
				request.post({
					uri: URL + 'items/' + CONTACT_TABLE + '/get',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						Offset: 0,
						View: {
							ColumnFilterHash: {
								ClassA: RPI		// RPI
							}
						}
					})
				}, function(error, response, body){
					if (!error && response.statusCode === 200) {
						const bodyJson = JSON.parse(body);
						if (bodyJson.Response.TotalCount <= 0){
							request.post({
								uri: URL + 'items/' + CONTACT_TABLE + '/create',
								headers: { "Content-type": "application/json;charset=utf-8" },
								body: JSON.stringify({
									ApiVersion: 1.1,
									ApiKey: API_KEY,
									ClassHash: {
										ClassA: RPI		// RPI
									},
									DateHash: {
										DateA: get_datetime_string(data.Time)		// 日時
									},
									CheckHash: {
										CheckA: true
									}
								})
							});
						}
						else {
							bodyJson.Response.Data.forEach(responseData => {
								request.post({
									uri: URL + 'items/' + responseData.ResultId +'/update',
									headers: { "Content-type": "application/json;charset=utf-8" },
									body: JSON.stringify({
										ApiVersion: 1.1,
										ApiKey: API_KEY,
										DateHash: {
											DateA: get_datetime_string(data.Time)		// 日時
										},
										CheckHash: {
											CheckA: true
										}
									})
								});
							});
						}
					}
				});
			});
		});
	});
	request.post({
		uri: URL + 'items/' + CONTACT_COUNT_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			var data = bodyJson.Response.Data[0];
			request.post({
				uri: URL + 'items/' + data.ResultId +'/update',
				headers: { "Content-type": "application/json;charset=utf-8" },
				body: JSON.stringify({
					ApiVersion: 1.1,
					ApiKey: API_KEY,
					NumHash: {
						NumA: data.NumHash.NumA + 1	// 陽性者数
					}
				})
			});
			res.sendStatus(200);
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//陽性削除
exports.delete_positive = function(res, req){
	var positive = false;
	var contact = false;
	req.body.data.forEach(data => {
		data.ENIN.forEach(ENIN => {
			CalcRPI(data.TEK, parseInt(ENIN, 16)).then(RPI => {
				request.post({
					uri: URL + 'items/' + CONTACT_TABLE + '/get',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						Offset: 0,
						View: {
							ColumnFilterHash: {
								ClassA: RPI		// RPI
							}
						}
					})
				}, function(error, response, body){
					if (!error && response.statusCode === 200) {
						const bodyJson = JSON.parse(body);
						bodyJson.Response.Data.forEach(data => {
							positive |= data.CheckHash.CheckA;
							contact |= data.CheckHash.CheckB;
							request.post({
								uri: URL + 'items/' + data.ResultId +'/delete',
								headers: { "Content-type": "application/json;charset=utf-8" },
								body: JSON.stringify({
									ApiVersion: 1.1,
									ApiKey: API_KEY
								})
							});
						});
					}
				});
			});
		});
	});
	request.post({
		uri: URL + 'items/' + CONTACT_COUNT_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			var data = bodyJson.Response.Data[0];
			request.post({
				uri: URL + 'items/' + data.ResultId +'/update',
				headers: { "Content-type": "application/json;charset=utf-8" },
				body: JSON.stringify({
					ApiVersion: 1.1,
					ApiKey: API_KEY,
					NumHash: {
						NumA: (data.NumHash.NumA - (positive) ? 1 : 0),	// 陽性者数
						NumB: (data.NumHash.NumB - (contact) ? 1 : 0),	// 濃厚接触数
					}
				})
			});
			res.sendStatus(200);
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//濃厚接触登録
exports.create_contact = function(res, req){
	req.body.data.forEach(data => {
		data.ENIN.forEach(ENIN => {
			CalcRPI(data.TEK, parseInt(ENIN, 16)).then(RPI => {
				request.post({
					uri: URL + 'items/' + CONTACT_TABLE + '/get',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						Offset: 0,
						View: {
							ColumnFilterHash: {
								ClassA: RPI		// RPI
							}
						}
					})
				}, function(error, response, body){
					if (!error && response.statusCode === 200) {
						const bodyJson = JSON.parse(body);
						if (bodyJson.Response.TotalCount <= 0){
							request.post({
								uri: URL + 'items/' + CONTACT_TABLE + '/create',
								headers: { "Content-type": "application/json;charset=utf-8" },
								body: JSON.stringify({
									ApiVersion: 1.1,
									ApiKey: API_KEY,
									ClassHash: {
										ClassA: RPI		// RPI
									},
									DateHash: {
										DateA: get_datetime_string(data.Time)		// 日時
									},
									CheckHash: {
										CheckB: true
									}
								})
							});
						}
						else {
							bodyJson.Response.Data.forEach(responseData => {
								request.post({
									uri: URL + 'items/' + responseData.ResultId +'/update',
									headers: { "Content-type": "application/json;charset=utf-8" },
									body: JSON.stringify({
										ApiVersion: 1.1,
										ApiKey: API_KEY,
										DateHash: {
											DateA: get_datetime_string(data.Time)		// 日時
										},
										CheckHash: {
											CheckB: true
										}
									})
								});
							});
						}
					}
				});
			});
		});
	});
	request.post({
		uri: URL + 'items/' + CONTACT_COUNT_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			var data = bodyJson.Response.Data[0];
			request.post({
				uri: URL + 'items/' + data.ResultId +'/update',
				headers: { "Content-type": "application/json;charset=utf-8" },
				body: JSON.stringify({
					ApiVersion: 1.1,
					ApiKey: API_KEY,
					NumHash: {
						NumB: data.NumHash.NumB + 1	// 濃厚接触者数
					}
				})
			});
			res.sendStatus(200);
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
		}
	});
}

//濃厚接触確認
exports.get_contact = function(res, req){
	var resData = [];
	var len = req.body.data.length;
	if(len > 0){
		var count = 0;
		for(var i = 0; i < len; i++){
			var data = req.body.data[i];
			request.post({
				uri: URL + 'items/' + CONTACT_TABLE + '/get',
				headers: { "Content-type": "application/json;charset=utf-8" },
				body: JSON.stringify({
					ApiVersion: 1.1,
					ApiKey: API_KEY,
					Offset: 0,
					View: {
						ColumnFilterHash: {
							ClassA: data.RPI		// RPI
						}
					}
				})
			}, function(error, response, body){
				count++;
				if (!error && response.statusCode === 200) {
					const bodyJson = JSON.parse(body);
					if(bodyJson.Response.Data.length > 0){
						var data = bodyJson.Response.Data[0];
						contactData = {
							Time: get_datetime_vale(data.DateHash.DateA),
							Type: (data.CheckHash.CheckA === true) ? 1 : 0,
							RPI: data.ClassHash.ClassA
						};
						resData.push(contactData);
					}
					if(count == len){
						res.json(resData)
					}
				}
			});
		}
	}else{
		res.json(resData)
	}
}

async function CalcRPI(TEK, ENIN) {
	var RPI = await hkdf(Buffer.from(''), Buffer.from(TEK), Buffer.from('EN-RPIK'), 16, 'SHA-256').then((RPIK) => {
		let PaddedData = new Uint8Array(16);
		let rpi_utf8 = utf8.encode("EN-RPI");
		for(let i = 0; i < 6; i++) {
			PaddedData[i] = rpi_utf8.charCodeAt(i);
		}
		for(let i = 6; i < 12; i++) {
			PaddedData[i] = 0x00;
		}
		PaddedData[12] = (ENIN >>> 24) & 0xff;
		PaddedData[13] = (ENIN >>> 16) & 0xff;
		PaddedData[14] = (ENIN >>> 8) & 0xff;
		PaddedData[15] = ENIN & 0xff;
		var cipher = crypto.createCipher('aes128', new Uint8Array(RPIK));
		cipher.update(PaddedData);
		var RPI = cipher.final();
		return RPI;
	});
	return RPI.toString('hex');
}

//時刻取得
var get_datetime_string = function(datetime){
	let datetimeStr = datetime.toString(10);
	var ret = datetimeStr.slice(0, 4) + '-' + datetimeStr.slice(4, 6) + '-' + datetimeStr.slice(6, 8) + 'T' +
				datetimeStr.slice(8, 10) + ':' + datetimeStr.slice(10, 12) + ':' + datetimeStr.slice(12, 14);
	return ret;
}

//時刻取得
var get_datetime_vale = function(datetimeStr){
	const regex = /-|T|:/g;
	var ret = Number(datetimeStr.replace(regex, ''));
	return ret;
}

// 残り日数取得
async function GetValidDays(authCode, setDays, add) {
	request.post({
		uri: URL + 'items/' + AUTH_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					ClassA: authCode,	// 認証コード
					CheckA: false		// 休止中でない
				}
			}
		})
	}, function(error, response, body){
		var validDays = setDays;
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.Data.length > 0){
				var data = bodyJson.Response.Data[0];
				if(add === true){
					validDays += data.NumHash.NumA;
				}
				request.post({
					uri: URL + 'items/' + data.ResultId +'/update',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						NumHash: {
							NumA: validDays		// 残り日数
						},
						DateHash: {
							DateA: moment().format("YYYY-MM-DD")
						}
					})
				});
				return validDays;
			}
		}
	});
}

// 一時パスワード取得
var TemporaryPassword = function(res) {
	request.post({
		uri: URL + 'items/' + TEMPPASSWORD_TABLE + '/get',
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
				res.statusCode = 402;
				res.json({Error, Message : 'Not Temporary Password' });
			}
		}
		else{
			res.statusCode = response.statusCode;
			res.json({Error, Message : response.Message });
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
