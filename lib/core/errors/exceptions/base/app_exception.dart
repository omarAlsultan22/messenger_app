import 'package:flutter/cupertino.dart';
import '../../../presentation/widgets/states/error_state.dart';


abstract class AppException implements Exception {
  final int? statusCode;
  final String? message;
  final dynamic error;
  final String? code;

  const AppException({
    this.error,
    this.message,
    this.statusCode,
    this.code,
  });

  Widget buildErrorWidget({VoidCallback? onRetry}) {
    return ErrorStateWidget(
        message: error,
        onRetry: onRetry
    );
  }
}