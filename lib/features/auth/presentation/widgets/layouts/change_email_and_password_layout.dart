import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import '../../utils/validate/email_validation.dart';
import '../../utils/validate/password_validation.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spaces.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_paddings.dart';
import '../../../../../core/data/models/message_result_model.dart';
import '../../../../../core/presentation/widgets/text_form_field.dart';
import '../../../../../core/presentation/widgets/build_snack_bar.dart';
import '../../../../../core/presentation/widgets/icon_button_widget.dart';
import '../../../../../core/data/data_sources/local/shared_preferences.dart';
import 'package:test_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:test_app/features/auth/presentation/utils/validate/form_validation.dart';


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

class _ChangeEmailAndPasswordLayoutState extends State<ChangeEmailAndPasswordLayout> with AuthMixin<ChangeEmailAndPasswordLayout> {
  bool _isPressed = true;
  bool _isObscureNew = true;
  bool _isObscureCurrent = true;
  bool _isObscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  //controllers
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatNewPasswordController = TextEditingController();

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
    handleMessageResult(
        messageResult: widget.messageResult,
        onNavigate: () => navigateToScreen(const SignInScreen()),
        onClear: _clearUserData
    );
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
        style: buttonStyle(padding: _paddingHorizontal),
        onPressed: widget.messageResult.isLoading
            ? () => _onSavePressed()
            : null,
        child: buildButtonContent(
            text: 'Save',
            isSaveButton: true,
            isLoading: widget.messageResult.isLoading
        ),
      ),
    );
  }

  Widget _buildBody() {
    return IgnorePointer(
      ignoring: widget.messageResult.isLoading,
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
    );
  }

  Widget _buildEmailField() {
    return BuildInputField(
      controller: _newEmailController,
      hintText: 'You can add a new email',
      prefixIcon: const Icon(Icons.email, color: AppColors.white),
      validator: (value) => EmailValidation.validator(value),
    );
  }

  Widget _buildCurrentPasswordField() {
    return BuildInputField(
      controller: _currentPasswordController,
      hintText: 'Current Password',
      prefixIcon: const Icon(Icons.lock, color: AppColors.white),
      obscureText: _isObscureCurrent,
      suffixIcon: buildPasswordVisibilityToggle(isObscure: _isObscureCurrent,
          onToggle: () =>
              setState(() => _isObscureCurrent = !_isObscureCurrent)),
      validator: (value) => PasswordValidation.validator(value),
    );
  }

  Widget _buildNewPasswordField() {
    return BuildInputField(
      controller: _newPasswordController,
      hintText: 'New password',
      prefixIcon: const Icon(Icons.lock, color: AppColors.white),
      obscureText: _isObscureNew,
      suffixIcon: buildPasswordVisibilityToggle(
          isObscure: _isObscureNew,
          onToggle: () =>
              setState(() => _isObscureNew = !_isObscureNew)),
      validator: (value) => PasswordValidation.validator(value),
    );
  }

  Widget _buildConfirmPasswordField() {
    return BuildInputField(
      controller: _repeatNewPasswordController,
      hintText: "Confirm the new password",
      prefixIcon: const Icon(Icons.lock_reset, color: AppColors.white),
      obscureText: _isObscureConfirm,
      suffixIcon: buildPasswordVisibilityToggle(
          isObscure: _isObscureConfirm,
          onToggle: () =>
              setState(() => _isObscureConfirm = !_isObscureConfirm)),
      validator: (value) => _validatePasswordConfirmation(value),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        AppSpaces.vertical_24,
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber),
        ),
      ],
    );
  }

  void _updateLockButton(bool value) {
    setState(() => _isPressed = value);
  }

  Future<void> _onSavePressed() async {
    if (!_validateForm()) return;
    _updateLockButton(false);
    hideKeyboard();
    widget.onUpdate(
        newEmail: _newEmailController.text.trim(),
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text
    );
    _updateLockButton(true);
  }

  bool _validateForm() {
    if (!FormValidation.validator(_formKey)) return false;

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
}