import '../../../features/auth/presentation/cubits/change_email_and_password_cubit.dart';
import '../../../features/auth/domain/use_cases/change_email_and_password_use_case.dart';
import '../../../features/auth/data/repositories_impl/sign_up_repository_impl.dart';
import '../../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../../features/auth/presentation/cubits/forget_password_cubit.dart';
import '../../../features/auth/domain/repositories/sign_up_repository.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/presentation/cubits/sign_in_cubit.dart';
import '../../../features/auth/presentation/cubits/sign_up_cubit.dart';
import '../../../features/auth/domain/use_cases/sign_in_use_case.dart';
import '../../../features/auth/domain/use_cases/sign_up_use_case.dart';
import '../../domain/data_sources/firestore/firestore_service.dart';
import 'package:test_app/core/services/data/session_service.dart';
import '../../network/domain/i_connectivity_service.dart';
import '../../domain/data_sources/auth_service.dart';
import '../service _locator.dart';


class AuthDependencies {
  static void register() {
    // Repositories
    sl.registerLazySingleton<AuthRepository>(() =>
        AuthRepositoryImpl(auth: sl<AuthService>()));

    sl.registerLazySingleton<SignUpRepository>(() =>
        SignUpRepositoryImpl(dataSource: sl<FirestoreService>()));

    // UseCases
    sl.registerLazySingleton<SignInUseCase>(() =>
        SignInUseCase(
            sessionService: sl<SessionService>(),
            authRepository: sl<AuthRepository>()));

    sl.registerLazySingleton<SignUpUseCase>(() =>
        SignUpUseCase(
            authRepository: sl<AuthRepository>(),
            signUpRepository: sl<SignUpRepository>()));

    sl.registerLazySingleton<ChangeEmailAndPasswordUseCase>(() =>
        ChangeEmailAndPasswordUseCase(
            authRepository: sl<AuthRepository>()));

    // Cubits
    sl.registerFactory<SignInCubit>(() =>
        SignInCubit(
            useCase: sl<SignInUseCase>(),
            connectivityService: sl<IConnectivityService>()));

    sl.registerFactory<SignUpCubit>(() =>
        SignUpCubit(
            useCase: sl<SignUpUseCase>(),
            connectivityService: sl<IConnectivityService>()));

    sl.registerFactory<ForgetPasswordCubit>(() =>
        ForgetPasswordCubit(
          authRepository: sl<AuthRepository>(),
          connectivityService: sl<IConnectivityService>(),
        ));

    sl.registerFactory<ChangeEmailAndPasswordCubit>(() =>
        ChangeEmailAndPasswordCubit(
            useCase: sl<ChangeEmailAndPasswordUseCase>(),
            connectivityService: sl<IConnectivityService>()));
  }
}