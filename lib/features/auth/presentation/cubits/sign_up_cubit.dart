import '../states/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/sign_up_useCase.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/mappers/error_handler.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/data/network/connectivity_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../../../core/errors/exceptions/network_app_exception.dart';


class SignUpCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState>{
  final SignUpUseCase _useCase;
  final ConnectivityService _connectivityService;

  SignUpCubit({
    required SignUpUseCase useCase,
    required ConnectivityService connectivityService,

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
      await _useCase.signUpExecute(
          firstName: firstName,
          lastName: lastName,
          userEmail: userEmail,
          userPassword: userPassword,
      );
      emit(AuthState(
          messageResult: MessageResult.success()));
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