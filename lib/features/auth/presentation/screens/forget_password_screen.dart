import '../../../../core/data/data_sources/remote/firebase_auth_service.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../widgets/layouts/forget_password_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/forget_password_cubit.dart';
import 'package:flutter/material.dart';
import '../states/auth_states.dart';


class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuthService();
    final authRepository = FirebaseAuthRepository(auth: auth);
    final connectivityService = ConnectivityService();
    final cubit = ForgetPasswordCubit(
      repository: authRepository,
      connectivityService: connectivityService,
    );
    return BlocBuilder<ForgetPasswordCubit, AuthState>(
        builder: (context, state) {
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
    );
  }
}
