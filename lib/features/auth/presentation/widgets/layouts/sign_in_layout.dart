import 'package:cash_money/features/auth/presentation/utils/validate/validate_email.dart';
import '../../../../../core/data/data_sources/local/shared_preferences.dart';
import 'package:cash_money/core/presentation/widgets/build_snack_bar.dart';
import 'package:cash_money/core/presentation/widgets/text_form_field.dart';
import 'package:cash_money/features/auth/constants/auth_hints_texts.dart';
import 'package:cash_money/core/presentation/widgets/loading_widget.dart';
import 'package:cash_money/core/constants/app_text_styles.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:cash_money/core/constants/app_paddings.dart';
import 'package:cash_money/core/constants/app_colors.dart';
import 'package:cash_money/core/constants/app_sizes.dart';
import 'package:cash_money/core/constants/app_keys.dart';
import '../../../../../core/constants/app_spaces.dart';
import '../../screens/forget_password_screen.dart';
import '../../utils/validate/validate_password.dart';
import '../../../constants/auth_lables_texts.dart';
import '../../../../home/screens/home_screen.dart';
import '../../screens/sign_up_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


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

class _SignInLayoutState extends State<SignInLayout> {
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.large,
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      AppSpaces.height_32,
                      _buildEmailField(),
                      AppSpaces.height_16,
                      _buildPasswordField(),
                      AppSpaces.height_24,
                      _buildLoginButton(),
                      AppSpaces.height_16,
                      _buildRegisterLink(),
                      _buildForgetPasswordLink()
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
          'LOGIN',
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
          'Login now to communicate with friends',
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

  Widget _buildEmailField() {
    return BuildInputField(
      controller: _emailController,
      labelText: AuthLabelsTexts.emailLabelText,
      hintText: AuthHintsTexts.emailHintText,
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: (value) => ValidateEmail.validator(value),
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
      autofillHints: const [AutofillHints.password],
      validator: (value) => ValidatePassword.validator(value),
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: _loginButtonStyle(),
        onPressed: widget.messageResult.isLoading ? () => _submitForm() : null,
        child: _buildLoginButtonContent(),
      ),
    );
  }

  Widget _buildLoginButtonContent() {
    return widget.messageResult.isLoading
        ? LoadingWidget.sizedBox
        : const Text(
        "LOGIN",
        style: AppTextStyles.textStyle
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
              fontSize: AppSizes.fontSize_16,
            ),
            children: [
              TextSpan(
                text: "Register Now",
                style: TextStyle(
                  color: AppColors.amber_500,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (
                  context) => const ForgetPasswordScreen(),
            ),
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
    final value = await widget.cacheHelper.getValue(key: AppKeys.uId);
    if (value?.isNotEmpty ?? false) {
      _navigateToHome();
    }
  }


  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _hideKeyboard();
      widget.onUpdate(
          userEmail: _emailController.text.trim(),
          userPassword: _passwordController.text
      );
    }
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  ButtonStyle _loginButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.amber_500,
      foregroundColor: AppColors.black,
      padding: AppPaddings.symmetricVertical,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2.0,
    );
  }
}