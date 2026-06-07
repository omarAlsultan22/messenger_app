import 'package:flutter/material.dart';
import 'package:test_app/features/auth/constants/auth_colors.dart';
import 'package:test_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:test_app/features/auth/presentation/widgets/navigator_with_delay.dart';
import '../../utils/validate/validate_email.dart';
import '../../utils/validate/validate_password.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spaces.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_borders.dart';
import '../../../../../core/data/models/message_result_model.dart';
import '../../../../../core/presentation/widgets/text_form_field.dart';
import '../../../../../core/presentation/widgets/build_snack_bar.dart';
import '../../../../../core/presentation/widgets/icon_button_widget.dart';
import '../../../../../core/data/data_sources/local/shared_preferences.dart';


class ChangeEmailAndPasswordLayout extends StatefulWidget {
  final void Function({
  required String newEmail,
  required String currentPassword,
  required String newPassword
  }) onUpdate;
  final CacheHelper cacheHelper;
  final MessageResult messageResult;
  const ChangeEmailAndPasswordLayout({
    super.key,
    required this.onUpdate,
    required this.cacheHelper,
    required this.messageResult,
    });

  @override
  State<ChangeEmailAndPasswordLayout> createState() => _ChangeEmailAndPasswordLayoutState();
}

class _ChangeEmailAndPasswordLayoutState extends State<ChangeEmailAndPasswordLayout> {
  bool _isObscureNew = true;
  bool _isObscureCurrent = true;
  bool _isObscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  //controllers
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatNewPasswordController = TextEditingController();

  //spaces
  static const _spacing = 20.0;
  static const _paddingHorizontal = AppPaddings.horizontalSymmetrical;

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatNewPasswordController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChangeEmailAndPasswordLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageResult.message != null) {
      _clearUserData();
      _showMessageResult();
      _navigateToHome();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent(context);
  }

  Widget _buildMainContent(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: AppSizes.none,
      leading: const IconButtonWidget(),
      title: const Text(
        'Change email and password',
        style: TextStyle(color: AppColors.white),
      ),
      actions: [_buildSaveButton()],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: _paddingHorizontal,
      child: ElevatedButton(
        style: _saveButtonStyle(),
        onPressed: widget.messageResult.isLoading
            ? () => _onSavePressed()
            : null,
        child: _buildSaveButtonContent(),
      ),
    );
  }

  Widget _buildSaveButtonContent() {
    return widget.messageResult.isLoading
        ? const SizedBox(
      width: _spacing,
      height: _spacing,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        color: AppColors.white,
      )
      ,
    ) : const Text(
      'Save',
      style: TextStyle(
        fontSize: AppSizes.sm,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildBody() {
    return IgnorePointer(
      ignoring: widget.messageResult.isLoading,
      child: Container(
        decoration: _buildBackgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.xLarge,
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildEmailField(),
                    AppSpaces.vertical_16,
                    _buildCurrentPasswordField(),
                    AppSpaces.vertical_16,
                    _buildNewPasswordField(),
                    AppSpaces.vertical_16,
                    _buildConfirmPasswordField(),
                    if (widget.messageResult
                        .isLoading) _buildLoadingIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return BuildInputField(
      controller: _newEmailController,
      hintText: 'You can add a new email',
      prefixIcon: Icons.email,
      validator: (value) => ValidateEmail.validator(value),
    );
  }

  Widget _buildCurrentPasswordField() {
    return BuildInputField(
      controller: _currentPasswordController,
      hintText: 'Current Password',
      prefixIcon: Icons.lock,
      obscureText: _isObscureCurrent,
      suffixIcon: _buildVisibilityToggle(isObscure: _isObscureCurrent,
          onToggle: (value) => setState(() => _isObscureCurrent = value)),
      validator: (value) => ValidatePassword.validator(value),
    );
  }

  Widget _buildNewPasswordField() {
    return BuildInputField(
      controller: _newPasswordController,
      hintText: 'New password',
      prefixIcon: Icons.lock,
      obscureText: _isObscureNew,
      suffixIcon: _buildVisibilityToggle(
          isObscure: _isObscureNew,
          onToggle: (value) =>
              setState(() => _isObscureNew = value)),
      validator: (value) => ValidatePassword.validator(value),
    );
  }

  Widget _buildConfirmPasswordField() {
    return BuildInputField(
      controller: _repeatNewPasswordController,
      hintText: "Confirm the new password",
      prefixIcon: Icons.lock_reset,
      obscureText: _isObscureConfirm,
      suffixIcon: _buildVisibilityToggle(
          isObscure: _isObscureConfirm,
          onToggle: (value) =>
              setState(() => _isObscureConfirm = value)),
      validator: _validatePasswordConfirmation(value),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        AppSpaces.vertical_24,
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AuthColors.amber_500),
        ),
      ],
    );
  }

  IconButton _buildVisibilityToggle({
    required bool isObscure,
    required void Function(bool) onToggle
  }) {
    return IconButton(
      icon: Icon(
        isObscure ? Icons.visibility_off : Icons.visibility,
        color: AuthColors.amber_600,
      ),
      onPressed: () => onToggle(!isObscure),
    );
  }

  Future<void> _onSavePressed() async {
    if (!_validateForm()) return;
    widget.onUpdate(
        newEmail: _newEmailController.text.trim(),
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text
    );
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_newPasswordController.text != _repeatNewPasswordController.text) {
      BuildSnackBar.show(
          context: context,
          message: 'The new password does not match',
          backgroundColor: AppColors.errorRed
      );
      return false;
    }

    return true;
  }

  void _clearUserData() {
    widget.cacheHelper.removeValue(key: 'uId');
  }

  String? _validatePasswordConfirmation(dynamic value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _showMessageResult() {
    BuildSnackBar.show(
      context: context,
      message: widget.messageResult.message!,
      backgroundColor: widget.messageResult.color!,
    );
  }

  void _navigateToHome(){
    NavigatorWithDelay.build(link: const SignInScreen(), context: context);
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AuthColors.brown_900,
          AuthColors.brown_800,
        ],
      ),
    );
  }

  ButtonStyle _saveButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AuthColors.amber_600,
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadius_12,
      ),
      padding: _paddingHorizontal,
    );
  }
}