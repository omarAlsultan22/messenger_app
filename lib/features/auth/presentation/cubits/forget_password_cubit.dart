import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../../../../core/errors/exceptions/validation_exception.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../../../core/errors/exceptions/network_app_exception.dart';
import 'package:test_app/features/auth/presentation/states/auth_states.dart';


class ForgetPasswordCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState> {
  final AuthRepository _authRepository;
  final ConnectivityService _connectivityService;

  ForgetPasswordCubit({
    required AuthRepository authRepository,
    required ConnectivityService connectivityService
  })
      : _authRepository = authRepository,
        _connectivityService = connectivityService,
        super(AuthState.initial());

  static ForgetPasswordCubit get(context) => BlocProvider.of(context);

  Future<void> sendResetEmail({
    required String userEmail
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      throw NetworkAppException();
    }
    if (userEmail.isEmpty) {
      throw ValidationException();
    }

    emit(AuthState(messageResult: MessageResult.loading()));

    try {
      await _authRepository.sendResetEmail(
        userEmail: userEmail,
      );
      emit(AuthState(
          messageResult: MessageResult.success(
              message: 'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني')));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              AuthState(messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }
}