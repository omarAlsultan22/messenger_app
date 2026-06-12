import 'package:test_app/features/auth/presentation/utils/validate/validate_email.dart';
import '../../../../../core/presentation/widgets/icon_button_widget.dart';
import '../../../../../core/presentation/widgets/build_snack_bar.dart';
import '../../../../../core/presentation/widgets/text_form_field.dart';
import '../../../../../core/presentation/widgets/loading_widget.dart';
import 'package:test_app/features/auth/constants/auth_strings.dart';
import '../../../../../core/data/models/message_result_model.dart';
import 'package:test_app/features/auth/constants/auth_colors.dart';
import 'package:test_app/core/constants/app_text_styles.dart';
import '../../../../../core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_spaces.dart';
import '../../../../../core/utils/validate_input.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../utils/validate/validate_password.dart';
import '../../screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import '../navigator_with_delay.dart';
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

class _SignUpLayoutState extends State<SignUpLayout> {
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
    if (widget.messageResult.message != null) {
      _showMessageResult(widget.messageResult);
      _navigateToHome();
    }
    setState(() {});
  }

  void _showMessageResult(MessageResult messageResult) {
    BuildSnackBar.show(
        context: context,
        message: messageResult.message!,
        backgroundColor: messageResult.color!
    );
  }

  void _navigateToHome() {
    NavigatorWithDelay.build(link: const SignInScreen(), context: context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildBackgroundDecoration(),
          child: Center(
            child: SingleChildScrollView(
              padding: AppPaddings.large,
              child: RepaintBoundary(
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        backgroundColor: AuthColors.brown_900,
        scrolledUnderElevation: AppSizes.none,
        leading: const IconButtonWidget()
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(AuthStrings.backgroundCover),
        fit: BoxFit.cover,
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
      validator: (value) => ValidateEmail.validator(value!),
    );
  }

  Widget _buildPasswordField() {
    return BuildInputField(
      controller: _passwordController,
      labelText: AuthStrings.passwordLabel,
      hintText: AuthStrings.passwordHint,
      prefixIcon: const Icon(Icons.lock, color: AppColors.white),
      obscureText: _isObscure,
      suffixIcon: _buildPasswordVisibilityToggle(),
      autofillHints: const [AutofillHints.newPassword],
      validator: (value) => ValidatePassword.validator(value!),
    );
  }

  Widget _buildPasswordVisibilityToggle() {
    return IconButton(
      icon: Icon(
        _isObscure ? Icons.visibility_off : Icons.visibility,
        color: AppColors.white,
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
      style: AppTextStyles.textStyle_18,
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
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      userEmail: _emailController.text.trim(),
      userPassword: _passwordController.text,
    );
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  ButtonStyle _registerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AuthColors.amber_500,
      foregroundColor: AppColors.black,
      padding: AppPaddings.verticalSymmetric,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.xl),
      ),
      elevation: 2.0,
    );
  }
}