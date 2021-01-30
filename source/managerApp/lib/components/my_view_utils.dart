import 'package:flutter/material.dart';

class ViewUtils {
  static String fullWidthNum(String input) {
    return input
        .replaceAll('0', '０')
        .replaceAll('1', '１')
        .replaceAll('2', '２')
        .replaceAll('3', '３')
        .replaceAll('4', '４')
        .replaceAll('5', '５')
        .replaceAll('6', '６')
        .replaceAll('7', '７')
        .replaceAll('8', '８')
        .replaceAll('9', '９');
  }
}

class MyText extends StatelessWidget {
  MyText(this.text, {Key key, this.fullWidthNum = true, this.color})
      : super(key: key);
  final String text;
  final Color color;
  final bool fullWidthNum;

  @override
  Widget build(BuildContext context) {
    return Text(
      fullWidthNum ? ViewUtils.fullWidthNum(text) : text,
      style: TextStyle(fontSize: 20.0, color: color),
    );
  }
}

class MyButton extends StatelessWidget {
  MyButton(this.text, {Key key, this.onPressed, this.page}) : super(key: key);
  final String text;
  final VoidCallback onPressed;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlatButton(
          onPressed: onPressed ??
              () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => page,
                      ),
                    )
                  },
          color: Colors.blue,
          textColor: Colors.white,
          padding: EdgeInsets.all(10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: MyText(text),
        ));
  }
}

class MyLoading extends StatelessWidget {
  MyLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}

class MyLoadError extends StatelessWidget {
  MyLoadError({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.error_outline,
      color: Colors.red,
      size: 60.0,
    );
  }
}
