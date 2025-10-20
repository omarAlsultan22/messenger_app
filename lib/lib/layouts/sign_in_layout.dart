import 'cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../layouts/messenger_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/components/constants.dart';
import '../../shared/components/components.dart';
import '../../shared/local/shared_preferences.dart';
import '../../shared/components/components.dart' as Fluttertoast;
import 'package:test_app/lib/shared/cubit_states/cubit_states.dart';


class SignInLayout extends StatefulWidget {
  const SignInLayout({super.key});

  @override
  State<SignInLayout> createState() => _SignInLayoutState();
}

class _SignInLayoutState extends State<SignInLayout> {
  final formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();

  bool result = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInCubit, CubitStates>(
      listener: _blocListener,
      builder: (BuildContext context, CubitStates state) {
        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, CubitStates state) {
    if (state is PhoneCodeSentState) {
      return _buildVerificationScreen(context, state);
    }
    return _buildPhoneInputScreen(context, state);
  }

  Widget _buildPhoneInputScreen(BuildContext context, CubitStates state) {
    final cubit = SignInCubit.get(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildBackgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAppIcon(),
                  const SizedBox(height: 30),
                  _buildWelcomeText(),
                  const SizedBox(height: 30),
                  _buildPhoneForm(cubit, state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationScreen(BuildContext context, CubitStates state) {
    final cubit = SignInCubit.get(context);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVerificationHeader(),
            const SizedBox(height: 20),
            _buildCodeInputField(),
            const SizedBox(height: 20),
            _buildVerifyButton(cubit),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return const Icon(
      CupertinoIcons.chat_bubble_2_fill,
      size: 150,
      color: Colors.white,
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      children: [
        Text(
          "Welcome to Messenger",
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

  Widget _buildPhoneForm(SignInCubit cubit, CubitStates state) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildPhoneField(),
          const SizedBox(height: 20),
          _buildSignInButton(cubit, state),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white),
      decoration: _buildPhoneFieldDecoration(),
      validator: (value) => _validatePhone(value),
    );
  }

  Widget _buildSignInButton(SignInCubit cubit, CubitStates state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 50,
      decoration: _buildSignInButtonDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _onSignInPressed(cubit),
          child: Center(
            child: state is LoadingState
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              'SIGN IN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationHeader() {
    return const Text(
      'Enter Verification Code',
      style: TextStyle(fontSize: 20, color: Colors.white),
    );
  }

  Widget _buildCodeInputField() {
    return TextField(
      controller: _smsCodeController,
      style: const TextStyle(color: Colors.white),
      decoration: _buildCodeFieldDecoration(),
    );
  }

  Widget _buildVerifyButton(SignInCubit cubit) {
    return ElevatedButton(
      style: _buildVerifyButtonStyle(),
      onPressed: () => _onVerifyPressed(cubit),
      child: const Text(
        'VERIFY NOW',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _blocListener(BuildContext context, CubitStates state) {
    if (state is SuccessState) {
      _navigateToMessengerScreen();
    }
    if (state is ErrorState) {
      _showErrorToast(state.error!);
    }
  }

  Future<void> _checkLoginStatus() async {
    await CacheHelper.getStringValue(key: 'isSigned').then((value) {
      if (value!.isNotEmpty) {
        _navigateToMessengerScreen();
      }
    });
  }

  void _onSignInPressed(SignInCubit cubit) {
    if (formKey.currentState!.validate()) {
      cubit.signInWithPhoneNumber(
        phone: _phoneController.text.trim(),
      );
    }
  }

  void _onVerifyPressed(SignInCubit cubit) {
    cubit.signInWithPhoneNumber(phone: _smsCodeController.text.trim());
  }

  void _navigateToMessengerScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Connected Successfully'),
        backgroundColor: Colors.green.shade700,
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MessengerScreen())
      );
    });
  }

  void _showErrorToast(String error) {
    showToast(
      message: error,
      state: ToastStates.ERROR,
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(backgroundCover),
        fit: BoxFit.cover,
      ),
    );
  }

  InputDecoration _buildPhoneFieldDecoration() {
    return InputDecoration(
      labelText: 'Phone Number',
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
      prefixIcon: const Icon(Icons.phone, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
    );
  }

  InputDecoration _buildCodeFieldDecoration() {
    return InputDecoration(
      hintText: '6-digit code',
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  BoxDecoration _buildSignInButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blueAccent.shade400,
          Colors.blue.shade800,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade800.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  ButtonStyle _buildVerifyButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      minimumSize: const Size(double.infinity, 50),
      elevation: 5,
    );
  }
}

// يمكن نقل هذه الدوال إلى ملف utilities منفصل
void showToast({
  required String message,
  required ToastStates state,
}) {
  Fluttertoast.showToast(
    msg: message,
  );
}

enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  switch (state) {
    case ToastStates.SUCCESS:
      return Colors.green;
    case ToastStates.ERROR:
      return Colors.red;
    case ToastStates.WARNING:
      return Colors.amber;
    default:
      return Colors.black;
  }
}