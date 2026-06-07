import 'package:test_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';
import '../../../../core/data/data_sources/remote/firebase_auth_service.dart';
import '../../../../core/data/data_sources/local/shared_preferences.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../../domain/useCases/sign_up_useCase.dart';
import '../widgets/layouts/sign_up_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../cubits/sign_up_cubit.dart';
import '../states/auth_states.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuthService();
    final repository = FirestoreBaseService();
    final cacheHelper = CacheHelper();
    final authRepository = FirebaseAuthRepository(auth: auth);
    final settingsRepository = FirestoreSettingsRepository(
        repository: repository, cacheHelper: cacheHelper);
    final useCase = SignUpUseCase(
        cacheHelper: cacheHelper,
        authRepository: authRepository,
        settingsRepository: settingsRepository
    );
    final connectivityService = ConnectivityService();
    final cubit = SignUpCubit(
        useCase: useCase,
        connectivityService: connectivityService
    );
    return BlocBuilder<SignUpCubit, AuthState>(
        builder: (context, state) {
          return SignUpLayout(
              messageResult: state.messageResult!,
              onUpdate: ({
                required String userName,
                required String userEmail,
                required String userPassword,
              }) =>
                  cubit.signUp(
                      userName: userName,
                      userEmail: userEmail,
                      userPassword: userPassword,
                  )
          );
        }
    );
  }
}