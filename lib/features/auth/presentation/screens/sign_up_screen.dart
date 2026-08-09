import '../../../../core/di/service _locator.dart';
import '../widgets/layouts/sign_up_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../cubits/sign_up_cubit.dart';
import '../states/auth_states.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<SignUpCubit>(),
        child: BlocBuilder<SignUpCubit, AuthState>(
            builder: (context, state) {
              final cubit = SignUpCubit.get(context);

              return SignUpLayout(
                  messageResult: state.messageResult!,
                  onUpdate: ({
                    required String firstName,
                    required String lastName,
                    required String userEmail,
                    required String userPassword,
                  }) =>
                      cubit.signUp(
                        firstName: firstName,
                        lastName: lastName,
                        userEmail: userEmail,
                        userPassword: userPassword,
                      )
              );
            }
        )
    );
  }
}