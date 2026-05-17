import '../states/sign_in_.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../auth/domain/useCases/sign_in_useCase.dart';
import '../../../../core/errors/exceptions/app_exception.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../conversation/domain/services/connectivity_service/connectivity_service.dart';


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
    required String phone,
  }) async {
    emit(AuthState(messageResult: MessageResult.loading()));
    try {
      if (phone.isEmpty) {
        throw('Fields cannot be empty.');
      }
      _useCase.signInExecute(
        phone: phone,
      );
      final isConnected = await _connectivityService.checkInternetConnection();
      emit(AuthState(
          messageResult: MessageResult.success(isConnected: isConnected)));
    } on AppException catch (e) {
      final exception = ErrorHandler.handleException(e);
      emit(AuthState(messageResult: MessageResult.error(error: exception)));
    }
  }
}