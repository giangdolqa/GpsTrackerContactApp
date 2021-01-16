const express = require('express')
const request = require('request')
const util    = require('util');
const bodyParser = require('body-parser')
const cors = require('cors');

const api_ver = '/api/v1/'
const port = 3000

const app = express()

var pleasanter = require("./pleasanter.js");

app.use(cors())

// urlencodedとjsonは別々に初期化
app.use(bodyParser.urlencoded({
  extended: true
}));
app.use(bodyParser.json());

//3000ポートでlisten
app.listen(port, () => {
	//確認用
	console.log('gps tracker api server is online on port ' + port + '.');
});


//POST ユーザ情報登録
app.post(api_ver + 'user', (res, req) => {
	pleasanter.create_user(req, res);
});

//PUT ユーザ情報変更
app.put(api_ver + 'user', (res, req) => {
	pleasanter.update_user(req, res);
});

//GET ユーザ情報取得
app.get(api_ver + 'user', (res, req) =>{
	pleasanter.get_user(req, res);
});

//DELETE ユーザ情報削除
app.delete(api_ver + 'user', (res, req) => {
	pleasanter.delete_user(req, res);
});

//PATCH 認証コード発行
app.patch(api_ver + 'auth/request', (res, req) => {
	pleasanter.request_auth(req, res);
});

//PATCH 認証コード確認
app.patch(api_ver + 'auth/verify', (res, req) => {
	pleasanter.verify_auth(req, res);
});

//PATCH SMS認証コード発行
app.patch(api_ver + 'auth/request/sms', (res, req) => {
	pleasanter.request_auth_sms(req, res);
});

//PATCH SMS認証コード確認
app.patch(api_ver + 'auth/verify/sms', (res, req) => {
	pleasanter.verify_auth_sms(req, res);
});

//POST デバイス情報登録
app.post(api_ver + 'device', (res, req) => {
	pleasanter.create_device(req, res);
});

//PUT デバイス情報変更
app.put(api_ver + 'device', (res, req) => {
	pleasanter.update_device(req, res);
});

//GET デバイス情報取得
app.get(api_ver + 'device', (res, req) => {
	pleasanter.get_device(req, res);
});

//DELETE デバイス情報削除
app.delete(api_ver + 'device', (res, req) => {
	pleasanter.delete_device(req, res);
});

//POST 認証コード登録
app.post(api_ver + 'device/code', (res, req) => {
	pleasanter.create_device_code(req, res);
});

//PATCH 認証コード適用
app.patch(api_ver + 'device/code/apply', (res, req) => {
	pleasanter.apply_device_code(req, res);
});

//POST 学校情報登録
app.post(api_ver + 'school', (res, req) => {
	pleasanter.create_school(req, res);
});

//PUT 学校情報変更
app.put(api_ver + 'school', (res, req) => {
	pleasanter.update_school(req, res);
});

//GET 学校情報取得
app.get(api_ver + 'school', (res, req) => {
	pleasanter.get_school(req, res);
});

//DELETE 学校情報削除
app.delete(api_ver + 'school', (res, req) => {
	pleasanter.delete_school(req, res);
});

//POST 陽性登録
app.post(api_ver + 'positive', (res, req) => {
	pleasanter.create_positive(req, res);
});

//DELETE 陽性削除
app.delete(api_ver + 'positive', (res, req) => {
	pleasanter.delete_positive(req, res);
});

//POST 濃厚接触登録
app.post(api_ver + 'contact', (res, req) => {
	pleasanter.create_contact(req, res);
});

//GET 濃厚接触確認
app.get(api_ver + 'contact', (res, req) => {
	pleasanter.get_contact(req, res);
});
