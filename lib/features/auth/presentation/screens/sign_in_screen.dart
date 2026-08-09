import '../../../../core/data/data_sources/local/shared_preferences.dart';
import '../../../../core/di/service _locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/sign_in_layout.dart';
import 'package:flutter/material.dart';
import '../cubits/sign_in_cubit.dart';
import '../states/auth_states.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<SignInCubit>(),
        child: BlocBuilder<SignInCubit, AuthState>(
            builder: (context, state) {
              final cubit = SignInCubit.get(context);
              return SignInLayout(
                  cacheHelper: sl<CacheHelper>(),
                  messageResult: state.messageResult!,
                  onUpdate: ({
                    required String userEmail,
                    required String userPassword
                  }) =>
                      cubit.signIn(
                          userEmail: userEmail, userPassword: userPassword
                      )
              );
            }
        )
    );
  }
}
