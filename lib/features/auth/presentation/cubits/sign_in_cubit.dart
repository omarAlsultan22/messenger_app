import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/sign_in_useCase.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../../../../core/errors/exceptions/validation_exception.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:test_app/features/auth/presentation/states/auth_states.dart';


class SignInCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState> {
  final SignInUseCase _useCase;
  final ConnectivityService _connectivityService;

  SignInCubit({
    required SignInUseCase useCase,
    required ConnectivityService connectivityService
  })
      : _useCase = useCase,
        _connectivityService = connectivityService,
        super(AuthState.initial());

  static SignInCubit get(context) => BlocProvider.of(context);

  Future<void> signIn({
    required String userEmail,
    required String userPassword,
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      throw SocketException;
    }

    emit(AuthState(messageResult: MessageResult.loading()));

    try {
      if (userEmail.isEmpty || userPassword.isEmpty) {
        throw ValidationException();
      }
      await _useCase.signInExecute(
          userEmail: userEmail,
          userPassword: userPassword
      );
      emit(AuthState(
          messageResult: MessageResult.success(
              message: 'تم تسجيل الدخول بنجاح')));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              AuthState(
                  messageResult: MessageResult.error(
                      error: failure)
              )
      );
    }
  }
}