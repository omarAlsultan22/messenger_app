import 'package:flutter/cupertino.dart';
import '../widgets/build_snack_bar.dart';


class UiUtils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void showMessageResult({
    required BuildContext context,
    required String message,
    required Color color,
  }) {
    BuildSnackBar.show(
        context: context,
        message: message,
        backgroundColor: color
    );
  }
}