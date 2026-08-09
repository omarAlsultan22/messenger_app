import '../../../features/edit_personal_account/data/repositories_impl/firestore_edit_personal_account_repository.dart';
import '../../../features/edit_personal_account/presentation/cubits/edit_personal_account_cubit.dart';
import '../../../features/edit_personal_account/domain/useCases/edit_personal_account_useCase.dart';
import '../../data/data_sources/remote/firestore/firestore_service.dart';
import '../service _locator.dart';


class EditPersonalAccountDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreEditPersonalAccountRepository(
            service: sl<FirestoreService>()));

    // UseCase
    sl.registerLazySingleton(() =>
        EditPersonalAccountUseCase(
            repository: sl<FirestoreEditPersonalAccountRepository>()));

    // Cubit
    sl.registerFactory(() =>
        EditPersonalAccountCubit(useCase: sl<EditPersonalAccountUseCase>(),
            repository: sl<FirestoreEditPersonalAccountRepository>()));
  }
}