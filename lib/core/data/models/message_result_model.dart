import 'dart:ui';
import '../../constants/app_colors.dart';
import '../../errors/exceptions/app_exception.dart';
import '../../presentation/utils/helpers/connection_ui_helper.dart';


class MessageResult {
  final String? error;
  final bool isLoading;
  final String? message;
  final Color? color;

  MessageResult({
    this.isLoading = false,
    this.message,
    this.error,
    this.color
  });


  factory MessageResult.loading(){
    return MessageResult(
        isLoading: true
    );
  }

  factory MessageResult.success({
    required bool isConnected
  }){
    return ConnectionUIHelper.getStatus(isConnected);
  }

  factory MessageResult.error({
    required AppException error
  }){
    return MessageResult(
        isLoading: false,
        color: AppColors.red_800,
        error: 'Update failed: ${error.message}',
    );
  }
}