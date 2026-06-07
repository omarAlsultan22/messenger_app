import 'package:flutter_bloc/flutter_bloc.dart';
import '../states/edit_personal_account_state.dart';
import '../../../../core/errors/mappers/error_handler.dart';
import '../../../../core/data/models/message_result_model.dart';
import 'package:test_app/core/presentation/states/app_sub_states.dart';
import 'package:test_app/features/edit_personal_account/domain/useCases/edit_personal_account_useCase.dart';
import 'package:test_app/features/edit_personal_account/data/repositories_impl/firestore_edit_personal_account_repository.dart';


class EditPersonalAccountCubit extends Cubit<EditPersonalAccountState> {
  final EditPersonalAccountUseCase _useCase;
  final FirestoreEditPersonalAccountRepository _repository;

  EditPersonalAccountCubit({
    required EditPersonalAccountUseCase useCase,
    required FirestoreEditPersonalAccountRepository repository
  })
      : _useCase = useCase,
        _repository = repository,
        super(EditPersonalAccountState.initial());

  static EditPersonalAccountCubit get(context) => BlocProvider.of(context);

  Future<void> getAccountData({
    required String docId
  }) async {
    emit(
        state.copyWith(
          subState: LoadingState(),
        ));
    try {
      final accountData = await _useCase.getAccountDataExecute(userId: docId);

      if(accountData == null) {
        state.copyWith(subState: InitialState());
        return;
      }

      emit(
          state.copyWith(
              subState: SuccessState(),
              firstModel: accountData
          )
      );
    }
    catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(error: exception)));
    }
  }

  Future<void> updateAccountData({
    required String userId,
    required String userImage,
    required String userName,
    required String userState,
  }) async {
    emit(state.copyWith(secondModel: MessageResult.loading()));
    try {
      _repository.updateAccountDataExecute(
          userId: userId,
          userImage: userImage,
          userName: userName,
          userState: userState
      );
      emit(state.copyWith(secondModel: MessageResult.success()));
    }
    catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(
          secondModel: MessageResult.error(error: exception)));
    }
  }
}