import '../../../features/edit_personal_account/data/repositories_impl/edit_personal_account_repository_impl.dart';
import '../../../features/edit_personal_account/presentation/cubits/edit_personal_account_cubit.dart';
import '../../../features/edit_personal_account/domain/use_cases/edit_personal_account_use_case.dart';
import '../../data/data_sources/remote/firestore/firestore_service_impl.dart';
import '../service _locator.dart';


class EditPersonalAccountDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        EditPersonalAccountRepositoryImpl(
            dataSource: sl<FirestoreServiceImpl>()));

    // UseCase
    sl.registerLazySingleton(() =>
        EditPersonalAccountUseCase(
            repository: sl<EditPersonalAccountRepositoryImpl>()));

    // Cubit
    sl.registerFactory(() =>
        EditPersonalAccountCubit(useCase: sl<EditPersonalAccountUseCase>(),
            repository: sl<EditPersonalAccountRepositoryImpl>()));
  }
}