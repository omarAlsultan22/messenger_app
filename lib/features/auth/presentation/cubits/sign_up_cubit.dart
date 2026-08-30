import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/sign_up_useCase.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../../../core/errors/exceptions/network_app_exception.dart';
import 'package:test_app/features/auth/presentation/states/auth_states.dart';


class SignUpCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState> {
  final SignUpUseCase _useCase;
  final ConnectivityService _connectivityService;

  SignUpCubit({
    required SignUpUseCase useCase,
    required ConnectivityService connectivityService
  })
      : _useCase = useCase,
        _connectivityService = connectivityService,
        super(AuthState.initial());

  static SignUpCubit get(context) => BlocProvider.of(context);

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String userEmail,
    required String userPassword,
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      throw NetworkAppException();
    }

    emit(AuthState(messageResult: MessageResult.loading()));

    try {
      await _useCase.signUpExecute(
        firstName: firstName,
        lastName: lastName,
        userEmail: userEmail,
        userPassword: userPassword,
      );
      emit(AuthState(
          messageResult: MessageResult.success(
              message: 'تم انشاء الحساب بنجاح')));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              AuthState(messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }
}