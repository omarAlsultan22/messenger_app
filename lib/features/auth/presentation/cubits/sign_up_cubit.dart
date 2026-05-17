import '../states/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/error_handler.dart';
import 'package:cash_money/core/data/models/message_result.dart';
import '../../../../core/errors/exceptions/network_exception.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:cash_money/features/auth/domain/useCases/sign_up_useCase.dart';
import '../../../../core/domain/services/connectivity_service/connectivity_service.dart';


class SignUpCubit extends Cubit<AuthState> {
  final SignUpUseCase _useCase;
  final ConnectivityService _connectivityService;

  SignUpCubit({
    required SignUpUseCase useCase,
    required ConnectivityService connectivityService,

  })
      : _useCase = useCase,
        _connectivityService = connectivityService,
        super(const AuthState());

  static SignUpCubit get(context) => BlocProvider.of(context);

  Future<void> signUp({
    required String userName,
    required String userEmail,
    required String userPassword,
    required String userPhone,
    required String userLocation,
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      emit(
        AuthState(
          messageResult: MessageResult.error(
              error: NetworkException(message: AppStrings.noInternetMessage)),
        ),
      );
      return;
    }
    emit(AuthState(messageResult: MessageResult.loading()));
    try {
      await _useCase.signUpExecute(
          userName: userName,
          userEmail: userEmail,
          userPassword: userPassword,
          userPhone: userPhone,
          userLocation: userLocation
      );
      emit(AuthState(
          messageResult: MessageResult.success()));
    } on AppException catch (e) {
      final exception = ErrorHandler.handleException(e);
      emit(AuthState(messageResult: MessageResult.error(error: exception)));
    }
  }
}