import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'sign_in_layout.dart';
import 'cubit.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SignInCubit(),
      child: const SignInLayout(),
    );
  }
}