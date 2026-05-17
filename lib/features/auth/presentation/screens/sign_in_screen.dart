import '../../../../core/domain/services/connectivity_service/connectivity_service.dart';
import 'package:cash_money/core/data/data_sources/local/shared_preferences.dart';
import 'package:cash_money/features/auth/presentation/cubits/sign_in_cubit.dart';
import 'package:cash_money/features/auth/domain/useCases/sign_in_useCase.dart';
import '../../../../core/data/data_sources/remote/firebase_auth.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/sign_in_layout.dart';
import 'package:flutter/material.dart';
import '../states/auth_states.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

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
        useCase: useCase, _connectivityService: connectivityService);
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
