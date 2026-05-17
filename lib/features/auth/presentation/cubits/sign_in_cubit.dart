import '../states/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:cash_money/core/data/models/message_result.dart';
import '../../../../core/errors/exceptions/network_exception.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:cash_money/features/auth/domain/useCases/sign_in_useCase.dart';
import '../../../../core/domain/services/connectivity_service/connectivity_service.dart';


class SignInCubit extends Cubit<AuthState> {
  final SignInUseCase _useCase;
  final ConnectivityService _connectivityService;

  SignInCubit({
    required SignInUseCase useCase,
    required ConnectivityService connectivityService
  })
      : _useCase = useCase,
        _connectivityService = connectivityService,
        super(const AuthState());

  static SignInCubit get(context) => BlocProvider.of(context);

  Future<void> signIn({
    required String userEmail,
    required String userPassword,
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
      if (userEmail.isEmpty || userPassword.isEmpty) {
        throw('Fields cannot be empty.');
      }
      _useCase.signInExecute(
          userEmail: userEmail,
          userPassword: userPassword
      );
      emit(AuthState(
          messageResult: MessageResult.success()));
    } on AppException catch (e) {
      final exception = ErrorHandler.handleException(e);
      emit(AuthState(messageResult: MessageResult.error(error: exception)));
    }
  }
}