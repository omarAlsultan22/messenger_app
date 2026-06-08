import '../states/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/mappers/error_handler.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../../../core/errors/exceptions/network_app_exception.dart';
import 'package:test_app/core/errors/exceptions/security_app_exception.dart';


class ForgetPasswordCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState>{
  final AuthRepository _repository;
  final ConnectivityService _connectivityService;

  ForgetPasswordCubit({
    required AuthRepository repository,
    required ConnectivityService connectivityService
  })
      : _repository = repository,
        _connectivityService = connectivityService,
        super(AuthState.initial());

  static ForgetPasswordCubit get(context) => BlocProvider.of(context);

  Future<void> sendResetEmail({
    required String userEmail
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      emit(
        AuthState(
          messageResult: MessageResult.error(
              error: NetworkAppException(
                  message: AppStrings.noInternetMessage)),
        ),
      );
      return;
    }
    emit(AuthState(messageResult: MessageResult.loading()));
    try {
      if (userEmail.isEmpty) {
        emit(
            AuthState(
              messageResult: MessageResult.error(
                  error: SecurityAppException(
                      message: 'Please enter your email')),
            )
        );
      }
      _repository.sendResetEmail(
        userEmail: userEmail,
      );
      emit(AuthState(
          messageResult: MessageResult.success(
              message: 'The reset link has been sent to your email')));
    } catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(AuthState(messageResult: MessageResult.error(error: exception)));
    }
  }
}