import '../../../features/home/data/repositories_impl/firestore_home_repository.dart';
import '../../../features/home/data/data_source/firestore_home_service.dart';
import '../../../features/home/domain/useCases/get_friends_use_case.dart';
import '../../../features/home/domain/useCases/get_profile_use_case.dart';
import '../../../features/home/presentation/cubits/home_cubit.dart';
import '../service _locator.dart';


class HomeDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreHomeRepository(service: sl<FirestoreHomeService>()));

    // UseCases
    sl.registerLazySingleton(() =>
        GetProfileUseCase(
            repository: sl<FirestoreHomeRepository>()));

    sl.registerLazySingleton(() =>
        GetFriendsUseCase(
            repository: sl<FirestoreHomeRepository>()));

    // Cubit
    sl.registerFactory(() =>
        HomeCubit(
            getProfileUseCase: sl<GetProfileUseCase>(),
            getFriendsUseCase: sl<GetFriendsUseCase>()));
  }
}