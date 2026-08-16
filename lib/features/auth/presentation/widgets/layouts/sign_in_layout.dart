import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import '../../screens/sign_up_screen.dart';
import '../../screens/forget_password_screen.dart';
import '../../utils/validate/form_validation.dart';
import '../../utils/validate/password_validation.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spaces.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import '../../../../../core/constants/app_paddings.dart';
import 'package:test_app/core/services/session_service.dart';
import '../../../../home/presentation/screens/home_screen.dart';
import '../../../../../core/data/models/message_result_model.dart';
import 'package:test_app/features/auth/constants/auth_strings.dart';
import '../../../../../core/presentation/widgets/text_form_field.dart';
import '../../../../../core/presentation/widgets/navigation/navigator.dart';
import '../../../../../core/data/data_sources/local/shared_preferences.dart';
import 'package:test_app/features/auth/presentation/widgets/build_app_icon.dart';
import 'package:test_app/features/auth/presentation/utils/validate/email_validation.dart';


class SignInLayout extends StatefulWidget {
  final void Function({
  required String userEmail,
  required String userPassword
  }) onUpdate;
  final CacheHelper cacheHelper;
  final MessageResult messageResult;
  const SignInLayout({
    super.key,
    required this.onUpdate,
    required this.cacheHelper,
    required this.messageResult
  });

  @override
  State<SignInLayout> createState() => _SignInLayoutState();
}

class _SignInLayoutState extends State<SignInLayout> with AuthMixin<SignInLayout> {
  bool _isPressed = true;
  bool _isObscure = true;

  final _formKey = GlobalKey<FormState>();

  //controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SignInLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleMessageResult(
      messageResult: widget.messageResult,
      onNavigate: () =>
          navigateToScreen(const HomeScreen()
          ),
    );
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
          child: Center(
            child: SingleChildScrollView(
              padding: AppPaddings.xLarge,
              child: RepaintBoundary(
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BuildAppIcon(),
                        AppSpaces.vertical_30,
                        _buildWelcomeText(),
                        AppSpaces.vertical_30,
                        _buildInputFields(),
                        AppSpaces.vertical_24,
                        _buildButtons()
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

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildEmailField(),
        AppSpaces.vertical_16,
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
        children: [
          _buildLoginButton(),
          AppSpaces.vertical_16,
          _buildRegisterLink(),
          _buildForgetPasswordLink()
        ]
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      children: [
        Text(
          "Welcome to Chat",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Connect with your Social Platform contacts",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
      validator: (value) => EmailValidation.validator(value),
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
      autofillHints: const [AutofillHints.password],
      validator: (value) => PasswordValidation.validator(value),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: buttonStyle(),
        onPressed: widget.messageResult.isLoading ? () => _submitForm() : null,
        child: buildButtonContent(
            text: 'SIGN IN',
            isLoading: widget.messageResult.isLoading
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: TextButton(
        onPressed: _navigateToRegister,
        child: RichText(
          text: const TextSpan(
            text: 'Don\'t have an account? ',
            style: TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: AppSizes.sm,
            ),
            children: [
              TextSpan(
                text: "SIGN UP",
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgetPasswordLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          BuildNavigator.build(
            link: const ForgetPasswordScreen(), context: context,
          );
        },
        child: const Text(
          'Forget password?',
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    if (SessionService().isLoggedIn && widget.messageResult.error == null) {
      navigateToScreen(const HomeScreen()
      );
    }
  }


  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _navigateToRegister() {
    BuildNavigator.build(link: const SignUpScreen(), context: context);
  }

  void _updateLockButton(bool value) {
    setState(() => _isPressed = value);
  }

  Future<void> _submitForm() async {
    if (FormValidation.validator(_formKey)) {
      _updateLockButton(false);
      hideKeyboard();
      widget.onUpdate(
          userEmail: _emailController.text.trim(),
          userPassword: _passwordController.text
      );
      _updateLockButton(true);
    }
  }
}