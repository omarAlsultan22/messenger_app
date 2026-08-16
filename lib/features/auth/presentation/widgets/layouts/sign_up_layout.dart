import 'package:test_app/features/auth/presentation/utils/validate/email_validation.dart';
import '../../../../../core/presentation/widgets/icon_button_widget.dart';
import '../../../../../core/presentation/widgets/text_form_field.dart';
import 'package:test_app/features/auth/constants/auth_strings.dart';
import '../../../../../core/data/models/message_result_model.dart';
import '../../../../../core/presentation/utils/ui_utils.dart';
import '../../../../../core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_spaces.dart';
import '../../../../../core/utils/validate_input.dart';
import '../../utils/validate/password_validation.dart';
import '../../../../../core/presentation/utils/form_validation.dart';
import 'package:flutter/material.dart';
import '../../mixins/auth_mixin.dart';
import '../build_app_icon.dart';


class SignUpLayout extends StatefulWidget {
  final void Function({
  required String firstName,
  required String lastName,
  required String userEmail,
  required String userPassword,
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

class _SignUpLayoutState extends State<SignUpLayout> with AuthMixin<SignUpLayout> {
  bool _isPressed = true;
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  //controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SignUpLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleMessageResult(
      messageResult: widget.messageResult,
      onNavigate: _navigateToBack,
    );
  }

  void _navigateToBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: buildBackgroundDecoration(),
          child: SingleChildScrollView(
            padding: AppPaddings.large,
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Align(
                          alignment: Alignment(-1.1, 0),
                          child: IconButtonWidget()
                      ),
                      const BuildAppIcon(),
                      const SizedBox(height: 30),
                      _buildHeader(context),
                      AppSpaces.vertical_24,
                      _buildInputFields(),
                      AppSpaces.vertical_24,
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
              fontSize: 24.0,
              color: AppColors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        AppSpaces.vertical_8,
        Text(
          'Register now to join the world of happiness',
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
              fontSize: 16,
              color: AppColors.white
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _buildFirstNameField()),
          const SizedBox(width: 15.0),
          Expanded(child: _buildLastNameField()),
        ]),
        AppSpaces.vertical_16,
        _buildEmailField(),
        AppSpaces.vertical_16,
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildFirstNameField() {
    return BuildInputField(
      controller: _firstNameController,
      labelText: 'First Name',
      hintText: 'Enter your first name',
      prefixIcon: const Icon(Icons.person, color: AppColors.white),
      autofillHints: const [AutofillHints.name],
      validator: (value) =>
          ValidateInput.validator(value: value!, item: 'first name'),
    );
  }

  Widget _buildLastNameField() {
    return BuildInputField(
      controller: _lastNameController,
      labelText: 'Last Name',
      hintText: 'Enter your last name',
      prefixIcon: const Icon(Icons.person, color: AppColors.white),
      autofillHints: const [AutofillHints.name],
      validator: (value) =>
          ValidateInput.validator(value: value!, item: 'last name'),
    );
  }

  Widget _buildEmailField() {
    return BuildInputField(
      controller: _emailController,
      labelText: AuthStrings.emailLabel,
      hintText: AuthStrings.emailHint,
      prefixIcon: const Icon(Icons.email, color: AppColors.white),
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: (value) => EmailValidation.validator(value!),
    );
  }

  Widget _buildPasswordField() {
    return BuildInputField(
      controller: _passwordController,
      labelText: AuthStrings.passwordLabel,
      hintText: AuthStrings.passwordHint,
      prefixIcon: const Icon(Icons.lock, color: AppColors.white),
      obscureText: _isObscure,
      suffixIcon: buildPasswordVisibilityToggle(
          isObscure: _isObscure, onToggle: _togglePasswordVisibility),
      autofillHints: const [AutofillHints.newPassword],
      validator: (value) => PasswordValidation.validator(value!),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: buttonStyle(),
        onPressed: _isPressed ? _submitForm : null,
        child: buildButtonContent(
            text: 'REGISTER',
            isLoading: widget.messageResult.isLoading
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _updateLockButton(bool value) {
    setState(() => _isPressed = value);
  }

  Future<void> _submitForm() async {
    if (FormValidation.validator(_formKey)) {
      _updateLockButton(false);
      UiUtils.hideKeyboard(context);
      await _performRegistration().whenComplete(() => _updateLockButton(true));
    }
  }

  Future<void> _performRegistration() async {
    widget.onUpdate(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      userEmail: _emailController.text.trim(),
      userPassword: _passwordController.text,
    );
  }
}