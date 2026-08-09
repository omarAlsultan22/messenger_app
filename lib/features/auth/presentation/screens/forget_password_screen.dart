import '../widgets/layouts/forget_password_layout.dart';
import '../../../../core/di/service _locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/forget_password_cubit.dart';
import 'package:flutter/material.dart';
import '../states/auth_states.dart';


class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<ForgetPasswordCubit>(),
        child: BlocBuilder<ForgetPasswordCubit, AuthState>(
            builder: (context, state) {
              final cubit = ForgetPasswordCubit.get(context);
              return ForgetPasswordLayout(
                  messageResult: state.messageResult!,
                  onUpdate: ({
                    required String userEmail,
                  }) =>
                      cubit.sendResetEmail(
                          userEmail: userEmail
                      )
              );
            }
        )
    );
  }
}
