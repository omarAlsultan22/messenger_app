import 'package:flutter/cupertino.dart';


class UiUtils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}