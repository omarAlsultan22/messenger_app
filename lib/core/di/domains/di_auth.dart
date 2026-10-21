import '../../../features/auth/presentation/cubits/change_email_and_password_cubit.dart';
import '../../../features/auth/domain/use_cases/change_email_and_password_use_case.dart';
import '../../../features/auth/data/repositories_impl/sign_up_repository_impl.dart';
import '../../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../../features/auth/presentation/cubits/forget_password_cubit.dart';
import '../../data/data_sources/remote/firestore/firestore_service_impl.dart';
import '../../../features/auth/presentation/cubits/sign_in_cubit.dart';
import '../../../features/auth/presentation/cubits/sign_up_cubit.dart';
import '../../../features/auth/domain/use_cases/sign_in_use_case.dart';
import '../../../features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:test_app/core/services/data/session_service.dart';
import '../../data/data_sources/remote/auth_service_impl.dart';
import '../../network/data/connectivity_service.dart';
import '../service _locator.dart';


class AuthDependencies {
  static void register() {
    // Repositories
    sl.registerLazySingleton(() =>
        AuthRepositoryImpl(auth: sl<AuthServiceImpl>()));

    sl.registerLazySingleton(() =>
        SignUpRepositoryImpl(dataSource: sl<FirestoreServiceImpl>()));

    // UseCases
    sl.registerLazySingleton(() =>
        SignInUseCase(
            sessionService: sl<SessionService>(),
            authRepository: sl<AuthRepositoryImpl>()));

    sl.registerLazySingleton(() =>
        SignUpUseCase(
            authRepository: sl<AuthRepositoryImpl>(),
            signUpRepository: sl<SignUpRepositoryImpl>()));

    sl.registerLazySingleton(() =>
        ChangeEmailAndPasswordUseCase(
            authRepository: sl<AuthRepositoryImpl>()));

    // Cubits
    sl.registerFactory(() =>
        SignInCubit(
            useCase: sl<SignInUseCase>(),
            connectivityService: sl<ConnectivityService>()));

    sl.registerFactory(() =>
        SignUpCubit(
            useCase: sl<SignUpUseCase>(),
            connectivityService: sl<ConnectivityService>()));

    sl.registerFactory(() =>
        ForgetPasswordCubit(
          authRepository: sl<AuthRepositoryImpl>(),
          connectivityService: sl<ConnectivityService>(),
        ));

    sl.registerFactory(() =>
        ChangeEmailAndPasswordCubit(
            useCase: sl<ChangeEmailAndPasswordUseCase>(),
            connectivityService: sl<ConnectivityService>()));
  }
}