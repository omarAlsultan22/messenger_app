import 'base/app_exception.dart';
import 'package:flutter/cupertino.dart';
import '../../../features/conversation/domain/services/connectivity_service/connectivity_service.dart';


class NetworkAppException extends AppException {
  final ConnectivityService? connectivityService;

  NetworkAppException({
    super.error,
    super.message,
    this.connectivityService
  });

  @override
  Widget buildErrorWidget({VoidCallback? onRetry}) {
    return InternetUnavailability(
      message: message,
      onRetry: onRetry,
      _connectivityService: connectivityService,
    );
  }
}