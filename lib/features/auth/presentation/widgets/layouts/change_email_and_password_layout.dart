import 'package:cash_money/core/presentation/widgets/icon_button_widget.dart';
import '../../../../../core/data/data_sources/local/shared_preferences.dart';
import 'package:cash_money/core/presentation/widgets/build_snack_bar.dart';
import 'package:cash_money/core/presentation/widgets/text_form_field.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:cash_money/core/constants/app_paddings.dart';
import 'package:cash_money/core/constants/app_colors.dart';
import 'package:cash_money/core/constants/app_sizes.dart';
import 'package:cash_money/core/constants/app_keys.dart';
import '../../../../../core/constants/app_spaces.dart';
import '../../utils/validate/validate_password.dart';
import '../../utils/validate/validate_email.dart';
import 'package:flutter/material.dart';


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
  static const _paddingHorizontal = EdgeInsets.symmetric(horizontal: 16);

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
      _showMessageResult(widget.messageResult);
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
        backgroundColor: AppColors.brown_900,
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
        fontSize: AppSizes.fontSize_16,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildBody() {
    const spaceBetweenFields = AppSpaces.height_16;

    return IgnorePointer(
      ignoring: widget.messageResult.isLoading,
      child: Container(
        decoration: _buildBackgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.large,
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildEmailField(),
                    spaceBetweenFields,
                    _buildCurrentPasswordField(),
                    spaceBetweenFields,
                    _buildNewPasswordField(),
                    spaceBetweenFields,
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
      validator: _validatePasswordConfirmation,
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        AppSpaces.height_24,
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber_500),
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
        color: AppColors.amber_600,
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
      BuildSnackBar.build(
          'The new password does not match', AppColors.errorRed);
      return false;
    }

    return true;
  }

  void _clearUserData() {
    widget.cacheHelper.removeData(key: AppKeys.uId);
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

  void _showMessageResult(MessageResult messageResult) {
    ScaffoldMessenger.of(context).showSnackBar(
        BuildSnackBar.build(messageResult.message!, messageResult.color!)
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.brown_900,
          AppColors.brown_800,
        ],
      ),
    );
  }

  ButtonStyle _saveButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.amber_600,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      padding: _paddingHorizontal,
    );
  }
}