const mail = require('nodemailer');

const transporter = mail.createTransport({
	host: 'marmo.sakura.ne.jp', // メールサーバー
	port: 587,
	secure: false,
	requireTLS: true,
	tls: {
		rejectUnauthorized: false,
	},
	auth: { // 認証情報
		user: 'support@marmo.sakura.ne.jp', // ユーザー名
		pass: 'KAvr9xREG7PbUmX', // パスワード
	}
});

//
// メールの送信
//
exports.send = (toaddress, passwd, willsend) => {
	if(willsend === false)
		return;

	let len = passwd.length;
	// メールメッセージ
	let mailOptions = {
		from: 'support@marmo.sakura.ne.jp', // 送信元メールアドレス
		to: '', // 送信先メールアドレス
		subject: '[marmo]メールアドレスの確認',
		text: '',
	};
	mailOptions.to = toaddress;
	mailOptions.text = 'marmoのお申込みいただき誠にありがとうございます。\n\n';
	mailOptions.text += `marmoの登録ページで、以下{$len}桁のメールアドレスの認証コードを入力してください。\n\n`;
	mailOptions.text += `認証コード：${passwd}\n\n`;
	mailOptions.text += 'コードの有効時間は30分です\n\n';
	mailOptions.text += '今後ともmarmoをよろしくお願いいたします。\n\n';
	mailOptions.text += '──────────────────────────────────';

	// メール送信
	return (async () => {
		const result = await transporter.sendMail(mailOptions).then(info => {
			return {
				flag: true,
				data: info
			};
		}).catch(error => {
			return {
				flag: false,
				data: error
			};
		});
		if (!result.flag) {
			console.log(result.data.stack);// メール送信失敗時のスタックトレース
		}
	})();
}
