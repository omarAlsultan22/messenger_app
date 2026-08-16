import 'package:flutter/cupertino.dart';
import '../widgets/build_snack_bar.dart';
import '../../data/models/message_result_model.dart';


class UiUtils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void showMessageResult({
    required BuildContext context,
    required MessageResult messageResult,
  }) {
    BuildSnackBar.show(
        context: context,
        message: messageResult.message!,
        backgroundColor: messageResult.color!
    );
  }
}