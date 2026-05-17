import 'package:cash_money/core/presentation/utils/helpers/validate/validator_input.dart';
import 'package:cash_money/features/auth/presentation/utils/validate/validate_email.dart';
import 'package:cash_money/core/presentation/widgets/icon_button_widget.dart';
import 'package:cash_money/core/presentation/widgets/build_snack_bar.dart';
import 'package:cash_money/core/presentation/widgets/text_form_field.dart';
import 'package:cash_money/features/auth/constants/auth_hints_texts.dart';
import 'package:cash_money/core/presentation/widgets/loading_widget.dart';
import 'package:cash_money/core/constants/app_labels_texts.dart';
import 'package:cash_money/core/constants/app_hints_texts.dart';
import 'package:cash_money/core/constants/app_text_styles.dart';
import 'package:cash_money/core/constants/app_paddings.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:cash_money/core/constants/app_colors.dart';
import 'package:cash_money/core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spaces.dart';
import '../../utils/validate/validate_password.dart';
import '../../../constants/auth_lables_texts.dart';
import 'package:flutter/material.dart';


class SignUpLayout extends StatefulWidget {
  final void Function({
  required String userName,
  required String userEmail,
  required String userPassword,
  required String userPhone,
  required String userLocation
  }) onUpdate;
  final MessageResult messageResult;

  const SignUpLayout({
    super.key,
    required this.onUpdate,
    required this.messageResult
  });

  @override
  State<SignUpLayout> createState() => _SignUpLayoutState();
}

class _SignUpLayoutState extends State<SignUpLayout> {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  //controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SignUpLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageResult.message != null) {
      _showMessageResult(widget.messageResult);
    }
    setState(() {});
  }

  void _showMessageResult(MessageResult messageResult) {
    ScaffoldMessenger.of(context).showSnackBar(
        BuildSnackBar.build(messageResult.message!, messageResult.color!)
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: AppColors.brown_900,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.medium,
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      AppSpaces.height_24,
                      _buildInputFields(),
                      AppSpaces.height_24,
                      _buildRegisterButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    const spaceBetweenFields = AppSpaces.height_16;

    return Column(
      children: [
        _buildNameField(),
        spaceBetweenFields,
        _buildEmailField(),
        spaceBetweenFields,
        _buildPasswordField(),
        spaceBetweenFields,
        _buildPhoneField(),
        spaceBetweenFields,
        _buildLocationField(),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        backgroundColor: AppColors.brown_900,
        scrolledUnderElevation: AppSizes.none,
        leading: const IconButtonWidget()
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create an Account',
          style: Theme
              .of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(
            color: AppColors.amber_500,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpaces.height_8,
        Text(
          'Register now to join the world of happiness',
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: AppColors.grey400,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return BuildInputField(
      controller: _nameController,
      labelText: AppLabelsTexts.name,
      hintText: AppHintsTexts.name,
      prefixIcon: Icons.person,
      autofillHints: const [AutofillHints.name],
      validator: (value) =>
          ValidateInput.validator(value!, AppLabelsTexts.name),
    );
  }

  Widget _buildEmailField() {
    return BuildInputField(
      controller: _emailController,
      labelText: AuthLabelsTexts.emailLabelText,
      hintText: AuthHintsTexts.emailHintText,
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: (value) => ValidateEmail.validator(value!),
    );
  }

  Widget _buildPasswordField() {
    return BuildInputField(
      controller: _passwordController,
      labelText: AuthLabelsTexts.passwordLabelText,
      hintText: AuthHintsTexts.passwordHintText,
      prefixIcon: Icons.lock,
      obscureText: _isObscure,
      suffixIcon: _buildPasswordVisibilityToggle(),
      autofillHints: const [AutofillHints.newPassword],
      validator: (value) => ValidatePassword.validator(value!),
    );
  }

  Widget _buildPhoneField() {
    return BuildInputField(
      controller: _phoneController,
      labelText: AppLabelsTexts.phoneNumber,
      hintText: AppHintsTexts.phoneNumber,
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      validator: (value) => ValidateInput.validator(value!, AppLabelsTexts.phoneNumber),
    );
  }

  Widget _buildLocationField() {
    return BuildInputField(
      controller: _locationController,
      labelText: AppLabelsTexts.location,
      hintText: AppHintsTexts.location,
      prefixIcon: Icons.location_on,
      validator: (value) => ValidateInput.validator(value!, AppLabelsTexts.location),
    );
  }

  Widget _buildPasswordVisibilityToggle() {
    return IconButton(
      icon: Icon(
        _isObscure ? Icons.visibility_off : Icons.visibility,
        color: AppColors.amber_500,
      ),
      onPressed: _togglePasswordVisibility,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: _registerButtonStyle(),
        onPressed: widget.messageResult.isLoading ? _submitForm : null,
        child: _buildRegisterButtonContent(),
      ),
    );
  }

  Widget _buildRegisterButtonContent() {
    return widget.messageResult.isLoading
        ? LoadingWidget.sizedBox
        : const Text(
      "REGISTER",
      style: AppTextStyles.textStyle,
    );
  }


  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _hideKeyboard();
      await _performRegistration();
    }
  }

  Future<void> _performRegistration() async {
    widget.onUpdate(
        userName: _nameController.text.trim(),
        userEmail: _emailController.text.trim(),
        userPassword: _passwordController.text,
        userPhone: _phoneController.text.trim(),
        userLocation: _locationController.text.trim()
    );
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  ButtonStyle _registerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.amber_500,
      foregroundColor: AppColors.black,
      padding: AppPaddings.symmetricVertical,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.medium),
      ),
      elevation: 2.0,
    );
  }
}