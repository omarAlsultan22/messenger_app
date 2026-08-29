import 'dart:ui';
import '../../constants/app_colors.dart';
import '../../errors/exceptions/base/app_exception.dart';


class MessageResult {
  final Color? color;
  final bool isLoading;
  final String? message;
  final AppException? error;

  const MessageResult({
    this.isLoading = false,
    this.message,
    this.error,
    this.color
  });

  factory MessageResult.initial(){
    return const MessageResult();
  }

  factory MessageResult.loading(){
    return const MessageResult(
        isLoading: true
    );
  }

  factory MessageResult.success({String? message}){
    return MessageResult(
        color: AppColors.successGreen,
        message: message ?? 'Updated Successfully'
    );
  }

  factory MessageResult.error({
    required AppException error
  }){
    return MessageResult(
      error: error,
      message: error.message!,
      color: AppColors.errorRed,
    );
  }
}