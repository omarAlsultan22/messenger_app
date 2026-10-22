import '../../../features/edit_personal_account/data/repositories_impl/edit_personal_account_repository_impl.dart';
import '../../../features/edit_personal_account/domain/repositories/edit_personal_account_repository.dart';
import '../../../features/edit_personal_account/presentation/cubits/edit_personal_account_cubit.dart';
import '../../../features/edit_personal_account/domain/use_cases/edit_personal_account_use_case.dart';
import '../../domain/data_sources/firestore/firestore_service.dart';
import '../service _locator.dart';


class EditPersonalAccountDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton<EditPersonalAccountRepository>(() =>
        EditPersonalAccountRepositoryImpl(
            dataSource: sl<FirestoreService>()));

    // UseCase
    sl.registerLazySingleton<EditPersonalAccountUseCase>(() =>
        EditPersonalAccountUseCase(
            repository: sl<EditPersonalAccountRepository>()));

    // Cubit
    sl.registerFactory<EditPersonalAccountCubit>(() =>
        EditPersonalAccountCubit(useCase: sl<EditPersonalAccountUseCase>(),
            repository: sl<EditPersonalAccountRepository>()));
  }
}