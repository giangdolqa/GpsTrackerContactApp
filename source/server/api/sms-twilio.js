//sms-twilio.js
const accountSid = 'AC21e4adaedb254d650e8024e90f540d73';
const authToken = "9c63aca13170ee9ac1505d7bdd69fb70";
const client = require('twilio')(accountSid, authToken);

//
// SMSの送信
//
exports.send = (toNumber, passwd, willsend) =>{
	if(willsend === false)
		return;

	var text = `\n認証コード：${passwd}\n\n`;
	text += 'marmoの登録ページで、SMSの認証コードを入力してください。\n';
	text += 'コードの有効時間は30分です\n';

	var toGlobalNumber = '+81' + toNumber.replace("-", "").slice(1);

	//SMSを送る
	client.messages.create({
		from: "+13347814681",
		to: toGlobalNumber,
		body: text,
	})
	.then(message => console.log(message.sid))
	.done();
}

