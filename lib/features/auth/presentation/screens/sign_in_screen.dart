import '../../../../core/data/data_sources/remote/firebase_auth_service.dart';
import '../../../../core/data/data_sources/local/shared_preferences.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../../domain/useCases/sign_in_useCase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/sign_in_layout.dart';
import 'package:flutter/material.dart';
import '../cubits/sign_in_cubit.dart';
import '../states/auth_states.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuthService();
    final cacheHelper = CacheHelper();
    final authRepository = FirebaseAuthRepository(auth: auth);
    final useCase = SignInUseCase(
        cacheHelper: cacheHelper,
        authRepository: authRepository);
    final connectivityService = ConnectivityService();
    final cubit = SignInCubit(
        useCase: useCase, connectivityService: connectivityService);
    return BlocBuilder<SignInCubit, AuthState>(
        builder: (context, state) {
          return SignInLayout(
              cacheHelper: cacheHelper,
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
    );
  }
}
