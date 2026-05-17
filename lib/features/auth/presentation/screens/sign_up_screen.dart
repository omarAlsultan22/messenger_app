import '../../../../core/domain/services/connectivity_service/connectivity_service.dart';
import 'package:cash_money/core/data/data_sources/local/shared_preferences.dart';
import 'package:cash_money/features/auth/presentation/cubits/sign_up_cubit.dart';
import 'package:cash_money/features/auth/domain/useCases/sign_up_useCase.dart';
import '../../../settings/data/repositories_impl/settings_repository.dart';
import 'package:cash_money/core/data/data_sources/remote/firestore.dart';
import '../../../../core/data/data_sources/remote/firebase_auth.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import '../widgets/layouts/sign_up_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../states/auth_states.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuthService();
    final repository = FirestoreService();
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
        useCase: useCase, _connectivityService: connectivityService);
    return BlocBuilder<SignUpCubit, AuthState>(
        builder: (context, state) {
          return SignUpLayout(
              messageResult: state.messageResult!,
              onUpdate: ({
                required String userName,
                required String userEmail,
                required String userPassword,
                required String userPhone,
                required String userLocation
              }) =>
                  cubit.signUp(
                      userName: userName,
                      userEmail: userEmail,
                      userPassword: userPassword,
                      userPhone: userPhone,
                      userLocation: userLocation
                  )
          );
        }
    );
  }
}