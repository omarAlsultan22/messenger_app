import '../../../features/home/data/repositories_impl/home_repository_impl.dart';
import '../../../features/home/domain/use_cases/get_friends_use_case.dart';
import '../../../features/home/domain/use_cases/get_profile_use_case.dart';
import '../../../features/home/domain/data_source/home_data_source.dart';
import '../../../features/home/domain/repositories/home_repository.dart';
import '../../../features/home/presentation/cubits/home_cubit.dart';
import '../../services/domain/i_notification_service.dart';
import '../service _locator.dart';


class HomeDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton<HomeRepository>(() =>
        HomeRepositoryImpl(dataSource: sl<HomeDataSource>()));

    // UseCases
    sl.registerLazySingleton<GetProfileUseCase>(() =>
        GetProfileUseCase(
            repository: sl<HomeRepository>()));

    sl.registerLazySingleton<GetFriendsUseCase>(() =>
        GetFriendsUseCase(
            repository: sl<HomeRepository>(),
            notificationService: sl<INotificationService>()
        )
    );

    // Cubit
    sl.registerFactory<HomeCubit>(() =>
        HomeCubit(
            getProfileUseCase: sl<GetProfileUseCase>(),
            getFriendsUseCase: sl<GetFriendsUseCase>()
        )
    );
  }
}