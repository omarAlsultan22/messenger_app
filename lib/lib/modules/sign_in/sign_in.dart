import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/lib/shared/cubit_states/cubit_states.dart';
import '../../layouts/messenger_screen.dart';
import '../../shared/components/components.dart';
import '../../shared/components/components.dart' as Fluttertoast;
import '../../shared/components/constants.dart';
import '../../shared/local/shared_preferences.dart';
import 'cubit.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  bool result = false;

  void navigateToMessengerScreen(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Connected Successfully'),
        backgroundColor: Colors.green.shade700,
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const MessengerScreen()));
    });
  }

  Future<void> checkLogIn() async {
    await CacheHelper.getStringValue(key: 'isSigned').then((value) {
      if (value!.isNotEmpty) {
        navigateToMessengerScreen();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkLogIn();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SignInCubit(),
      child: BlocConsumer<SignInCubit, CubitStates>(
        listener: (BuildContext context, CubitStates state) async {
          if (state is SuccessState) {
            navigateToMessengerScreen();
          }
          if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
          if (state is SuccessState) {
            showToast(
              message: 'Password reset link sent to your email',
              state: ToastStates.SUCCESS,
            );
          }
          if (state is ErrorState) {
            showToast(
              message: state.error,
              state: ToastStates.ERROR,
            );
          }
        },
        builder: (BuildContext context, CubitStates state) {
          var cubit = SignInCubit.get(context);
          if (state is PhoneCodeSentState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enter Verification Code',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _smsCodeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '6-digit code',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 5,
                    ),
                    onPressed: () {
                      cubit.signInWithPhoneNumber(phone: _smsCodeController.text.trim(),);
                    },
                    child: const Text(
                      'VERIFY NOW',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(backgroundCover),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.chat_bubble_2_fill,
                          size: 150,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Welcome to Messenger",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Connect with your Social Platform contacts",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
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
                                ),
                                validator: (value) => validator(value, 'phone'),
                              ),
                              const SizedBox(height: 20),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
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
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        cubit.signInWithPhoneNumber(
                                          phone: _phoneController.text.trim(),
                                        );
                                      }
                                    },
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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