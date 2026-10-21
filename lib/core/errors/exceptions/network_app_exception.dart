import 'base/app_exception.dart';
import 'package:flutter/cupertino.dart';
import '../../network/data/connectivity_service.dart';
import '../../presentation/widgets/internet_unavailability.dart';


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
      connectivityService: connectivityService,
    );
  }
}