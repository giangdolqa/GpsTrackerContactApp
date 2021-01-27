import 'package:flutter/services.dart';

// Util for input formatting
class InputFormatUtil {
  // English
  static TextInputFormatter OnlyEnglish =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+'));

  // number
  static TextInputFormatter OnlyNumber =
      FilteringTextInputFormatter.allow(RegExp(r'\d+'));

  // English + number
  static TextInputFormatter OnlyEnglishAndNumber =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]+'));

  // English + number
  static TextInputFormatter OnlyEnglishNumberSpaceSlash =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9/ ]+'));

  // Money
  static TextInputFormatter OnlyMoney =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]+'));
}
