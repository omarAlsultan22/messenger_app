import '../navigator_with_delay.dart';
import 'package:flutter/material.dart';
import '../../screens/sign_up_screen.dart';
import '../../screens/forget_password_screen.dart';
import '../../utils/validate/validate_password.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spaces.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import '../../../../../core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/services/session_service.dart';
import '../../../../home/presentation/screens/home_screen.dart';
import '../../../../../core/data/models/message_result_model.dart';
import 'package:test_app/features/auth/constants/auth_colors.dart';
import 'package:test_app/features/auth/constants/auth_strings.dart';
import '../../../../../core/presentation/widgets/loading_widget.dart';
import '../../../../../core/presentation/widgets/text_form_field.dart';
import '../../../../../core/presentation/widgets/build_snack_bar.dart';
import '../../../../../core/data/data_sources/local/shared_preferences.dart';
import 'package:test_app/features/auth/presentation/widgets/build_app_icon.dart';
import 'package:test_app/features/auth/presentation/utils/validate/validate_email.dart';


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
      if (widget.messageResult.error == null) {
        _navigateToHome();
      }
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

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: AuthColors.brown_900,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildBackgroundDecoration(),
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

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(AuthStrings.backgroundCover),
        fit: BoxFit.cover,
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
      validator: (value) => ValidateEmail.validator(value),
    );
  }

  Widget _buildPasswordField() {
    return BuildInputField(
      controller: _passwordController,
      labelText: AuthStrings.passwordLabel,
      hintText: AuthStrings.passwordHint,
      prefixIcon: Icon(Icons.lock, color: AppColors.white),
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
        color: AuthColors.amber_500,
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
        "SIGN IN",
        style: TextStyle(
          fontSize: AppSizes.sm,
          letterSpacing: 1.2,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )
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
                  color: AuthColors.amber_500,
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
              builder: (context) => const ForgetPasswordScreen(),
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
    if (SessionService().isLoggedIn && widget.messageResult.error == null) {
      _navigateToHome();
    }
  }


  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _navigateToRegister() {
    NavigatorWithDelay.build(link: const SignUpScreen(), context: context);
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
      backgroundColor: AuthColors.amber_500,
      foregroundColor: AppColors.black,
      padding: AppPaddings.verticalSymmetric,
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadius_16,
      ),
      elevation: 2.0,
    );
  }
}