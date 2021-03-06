const request = require('request');
const util    = require('util');
const bodyParser = require('body-parser')

const AUTH_TABLE			= '7'
const CONTACT_TABLE			= '9'
const CONTACT_COUNT_TABLE	= '17'

const URL = 'http://ik1-407-35954.vs.sakura.ne.jp/api/';
const API_KEY = 'b112d2d4dc3ccd0c24fd560174a94290b2281810e164d99b2cecc345f9c1ebafa5d691d29f0119768e694599020e7cd969bfa529ba369339773fe758bc044f5d';

//接触情報更新
const update_contact_table = new Promise((resolve, reject) => {
	request.post({
		uri: URL + 'items/' + CONTACT_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			var dayafter14 = new Date();
			dayafter14.setDate(dayafter14.getDay() - 14);
			dayafter14.setHours(0);
			dayafter14.setMinutes(0);
			dayafter14.setSeconds(0);
			bodyJson.Response.Data.forEach(data => {
				var data_date = new Date(data.DateHash.DateA);
				if(data_date >= dayafter14){
					return;
				}
				request.post({
					uri: URL + 'items/' + data.ResultId +'/delete',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY
					})
				});
			});
			resolve(1);
		}
	});
})

//接触情報数更新
const update_contact_count_table = new Promise((resolve, reject) => {
	request.post({
		uri: URL + 'items/' + CONTACT_COUNT_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			var dayafter14 = new Date();
			dayafter14.setDate(dayafter14.getDay() - 14);
			dayafter14.setHours(0);
			dayafter14.setMinutes(0);
			dayafter14.setSeconds(0);
			bodyJson.Response.Data.forEach(data => {
				var data_date = new Date(data.DateHash.DateA);
				if(data_date !== dayafter14){
					return;
				}
				var positiveCountDay = data.NumHash.NumA;
				var contactCountDay = data.NumHash.NumB;
				var date = '1899-12-30T00:00:00';
				request.post({
					uri: URL + 'items/' + CONTACT_COUNT_TABLE + '/get',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
					})
				}, function(error, response, body){
					if (!error && response.statusCode === 200) {
						const bodyJson = JSON.parse(body);
						bodyJson.Response.Data.forEach(data => {
							if(data.DateHash.DateA !== date){
								return;
							}
							var positiveCount = data.NumHash.NumA - positiveCountDay;
							var contactCount = data.NumHash.NumB - contactCountDay;
							request.post({
								uri: URL + 'items/' + data.ResultId +'/update',
								headers: { "Content-type": "application/json;charset=utf-8" },
								body: JSON.stringify({
									ApiVersion: 1.1,
									ApiKey: API_KEY,
									NumHash: {
										NumA: positiveCount,	// 陽性者数
										NumB: contactCount		// 濃厚接触者数
									}
								})
							});
						});
					}
				});
			});
			resolve(1);
		}
	});
})

// 残り日数更新
const update_auth_table = new Promise((resolve, reject) => {
	request.post({
		uri: URL + 'items/' + AUTH_TABLE + '/get',
		headers: { "Content-type": "application/json;charset=utf-8" },
		body: JSON.stringify({
			ApiVersion: 1.1,
			ApiKey: API_KEY,
			Offset: 0,
			View: {
				ColumnFilterHash: {
					CheckA: false		// 休止中でない
				}
			}
		})
	}, function(error, response, body){
		if (!error && response.statusCode === 200) {
			const bodyJson = JSON.parse(body);
			if (bodyJson.Response.Data.length > 0){
				var data = bodyJson.Response.Data[0];
				var validDays = data.NumHash.NumA - 1;
				if(validDays < 0)
					return;
				request.post({
					uri: URL + 'items/' + data.ResultId +'/update',
					headers: { "Content-type": "application/json;charset=utf-8" },
					body: JSON.stringify({
						ApiVersion: 1.1,
						ApiKey: API_KEY,
						NumHash: {
							NumA: validDays		// 残り日数
						}
					})
				});
			}
			resolve(1);
		}
	});
})


//接触情報更新
update_contact_table.then((value) => {
});
//接触情報数更新
update_contact_count_table.then((value) => {
});
//残り日数更新
update_auth_table.then((value) => {
});
