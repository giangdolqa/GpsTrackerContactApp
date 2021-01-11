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
	pleasanter.create_user(res, req);
});

//PUT ユーザ情報変更
app.put(api_ver + 'user', (res, req) => {
	pleasanter.update_user(res, req);
});

//GET ユーザ情報取得
app.get(api_ver + 'user', function(req,res){
	pleasanter.get_user(res, req);
});

//DELETE ユーザ情報削除
app.delete(api_ver + 'user', (res, req) => {
	pleasanter.delete_user(res, req);
});

//PUT 認証コード発行
app.put(api_ver + 'auth/request', (res, req) => {
	pleasanter.request_auth(res, req);
});

//PATCH 認証コード発行
app.patch(api_ver + 'auth/request', (res, req) => {
	pleasanter.request_auth(res, req);
});

//PATCH 認証コード確認
app.patch(api_ver + 'auth/verify', (res, req) => {
	pleasanter.verify_auth(res, req);
});

//POST デバイス情報登録
app.post(api_ver + 'device', (res, req) => {
	pleasanter.create_device(res, req);
});

//PUT デバイス情報変更
app.put(api_ver + 'device', (res, req) => {
	pleasanter.update_device(res, req);
});

//GET デバイス情報取得
app.get(api_ver + 'device', function(req,res){
	pleasanter.get_device(res, req);
});

//DELETE デバイス情報削除
app.delete(api_ver + 'device', (res, req) => {
	pleasanter.delete_device(res, req);
});

//POST 認証コード登録
app.post(api_ver + 'device/code', (res, req) => {
	pleasanter.create_device_code(res, req);
});

//PATCH 認証コード適用
app.patch(api_ver + 'device/code/apply', (res, req) => {
	pleasanter.apply_device_code(res, req);
});

//POST 学校情報登録
app.post(api_ver + 'school', (res, req) => {
	pleasanter.create_device(res, req);
});

//PUT 学校情報変更
app.put(api_ver + 'school', (res, req) => {
	pleasanter.update_device(res, req);
});

//GET 学校情報取得
app.get(api_ver + 'school', function(req,res){
	pleasanter.get_device(res, req);
});

//DELETE 学校情報削除
app.delete(api_ver + 'school', (res, req) => {
	pleasanter.delete_device(res, req);
});

//POST 陽性登録
app.post(api_ver + 'positive', (res, req) => {
	pleasanter.create_positive(res, req);
});

//DELETE 陽性削除
app.post(api_ver + 'positive', (res, req) => {
	pleasanter.delete_positive(res, req);
});

//POST 濃厚接触登録
app.post(api_ver + 'contact', (res, req) => {
	pleasanter.create_contact(res, req);
});

//GET 濃厚接触確認
app.get(api_ver + 'contact', (res, req) => {
	pleasanter.get_contact(res, req);
});
