import '../../../features/home/data/repositories_impl/home_repository_impl.dart';
import '../../../features/home/data/data_source/home_data_source_impl.dart';
import '../../../features/home/domain/use_cases/get_friends_use_case.dart';
import '../../../features/home/domain/use_cases/get_profile_use_case.dart';
import '../../../features/home/presentation/cubits/home_cubit.dart';
import '../service _locator.dart';


class HomeDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        HomeRepositoryImpl(service: sl<HomeDataSourceImpl>()));

    // UseCases
    sl.registerLazySingleton(() =>
        GetProfileUseCase(
            repository: sl<HomeRepositoryImpl>()));

    sl.registerLazySingleton(() =>
        GetFriendsUseCase(
            repository: sl<HomeRepositoryImpl>()));

    // Cubit
    sl.registerFactory(() =>
        HomeCubit(
            getProfileUseCase: sl<GetProfileUseCase>(),
            getFriendsUseCase: sl<GetFriendsUseCase>()));
  }
}