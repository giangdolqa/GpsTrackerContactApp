//sms-clickatell.js
const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const xhr = new XMLHttpRequest();

//
// SMSの送信
//
exports.send = (toNumber, passwd, willsend) =>{
	if(willsend === false)
		return;

	var text = `認証コード：${passwd}\n\n`;
	text += 'marmoの登録ページで、SMSの認証コードを入力してください。\n';
	text += 'コードの有効時間は30分です\n';
	text = encodeURI(text);

	var toGlobalNumber = '81' + toNumber.replace(/-/g, "").slice(1);

	//SMSを送る
	xhr.open("GET", "https://platform.clickatell.com/messages/http/send?apiKey=r-sFQa2tTxabXBFr5Fea7Q==&unicode=1&to=" + toGlobalNumber + "&content=" + text, true);
	xhr.onreadystatechange = function(){
		if (xhr.readyState == 4 && xhr.status == 200) {
			//console.log('success ' + toGlobalNumber);
		}else{
			//console.log('failure ' + toGlobalNumber);
		}
	};
	xhr.send();
}
