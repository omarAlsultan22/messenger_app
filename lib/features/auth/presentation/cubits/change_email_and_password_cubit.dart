import '../states/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../../domain/useCases/change_email_and_password_useCase.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:test_app/core/errors/exceptions/network_app_exception.dart';


class ChangeEmailAndPasswordCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState> {
  final ChangeEmailAndPasswordUseCase _useCase;
  final ConnectivityService _connectivityService;

  ChangeEmailAndPasswordCubit({
    required ChangeEmailAndPasswordUseCase useCase,
    required ConnectivityService connectivityService
  })
      : _useCase = useCase,
        _connectivityService = connectivityService,
        super(AuthState.initial());

  static ChangeEmailAndPasswordCubit get(context) => BlocProvider.of(context);

  Future<void> changeEmailAndPassword({
    required String newEmail,
    required String currentPassword,
    required String newPassword,
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      throw NetworkAppException();
    }
    emit(AuthState(messageResult: MessageResult.loading()));
    try {
      await _useCase.updateProfileExecute(
          newEmail: newEmail,
          newPassword: newPassword,
          currentPassword: currentPassword
      );
      emit(
          AuthState(messageResult: MessageResult.success()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              AuthState(
                messageResult: MessageResult.error(
                  error: failure,
                ),
              )
      );
    }
  }
}