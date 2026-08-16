import 'package:flutter/material.dart';
import '../../constants/auth_strings.dart';
import '../../constants/auth_text_style.dart';
import '../widgets/navigator_with_delay.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_borders.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/presentation/widgets/loading_widget.dart';
import '../../../../core/presentation/widgets/build_snack_bar.dart';


mixin AuthMixin<T extends StatefulWidget> on State<T> {

  static bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  BoxDecoration buildBackgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(AuthStrings.backgroundCover),
        fit: BoxFit.cover,
      ),
    );
  }

  void showMessageResult(MessageResult messageResult) {
    BuildSnackBar.show(
      context: context,
      message: messageResult.message!,
      backgroundColor: messageResult.color!,
    );
  }

  void handleMessageResult({
    required MessageResult messageResult,
    required VoidCallback onNavigate,
    VoidCallback? onClear,
  }) {
    if (messageResult.message != null) {
      showMessageResult(messageResult);
      if (messageResult.error == null) {
        onClear?.call();
        onNavigate();
      }
      setState(() {});
    }
  }

  Widget buildPasswordVisibilityToggle({
    required bool isObscure,
    required VoidCallback onToggle,
    Color iconColor = AppColors.amber,
  }) {
    return IconButton(
      icon: Icon(
        isObscure ? Icons.visibility_off : Icons.visibility,
        color: iconColor,
      ),
      onPressed: onToggle,
    );
  }

  Widget buildButtonContent({
    required bool isLoading,
    required String text,
    bool isSaveButton = false,
  }) {
    if (isLoading) {
      return isSaveButton
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: AppColors.white,
        ),
      )
          : LoadingWidget.sizedBox;
    }

    return Text(
      text,
      style: AuthTextStyles.textStyle_16,
    );
  }

  void navigateToScreen(Widget link) {
    NavigatorWithDelay.build(link: link, context: context);
  }

  ButtonStyle buttonStyle({EdgeInsetsGeometry? padding}) {
    return ElevatedButton.styleFrom(
      disabledBackgroundColor: AppColors.blue700,
      padding: padding ?? AppPaddings.verticalSymmetric,
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadius_16,
      ),
      elevation: 2.0,
    );
  }
}