import 'base/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/errors/exceptions/base/exception_handler.dart';


class FirebaseAIAppException extends AppException implements ExceptionHandler {
  FirebaseAIAppException({
    super.code,
    super.error,
    super.message
  });

  static final Map<String, AppException> _errorFactories = {
    'invalid-api-key': InvalidApiKeyAppException(
      code: 'invalid-api-key',
      message: 'Service temporarily unavailable. Please try again later.',
    ),

    'service-not-enabled': ServiceApiNotEnabledAppException(
      code: 'service-not-enabled',
      message: 'Service temporarily unavailable. Please try again later.',
    ),

    'server-error': ServerAppException(
      code: 'server-error',
      message: 'Something went wrong. Please try again in a few minutes.',
    ),

    'unsupported-location': UnsupportedUserLocationAppException(
      code: 'unsupported-location',
      message: 'This service is not available in your region yet.',
    ),

    'quota-exceeded': QuotaExceededAppException(
      code: 'quota-exceeded',
      message: 'Daily usage limit reached. Please try again tomorrow.',
    ),
  };


  @override
  bool canHandle() {
    return _errorFactories.containsKey((error as FirebaseException).code);
  }

  @override
  AppException handle() {
    if (canHandle()) {
      final exception = _errorFactories[(error as FirebaseException).code];
      if (exception != null) {
        return exception;
      }
    }
    return FirebaseAIAppException(message: message ??
        "An unexpected Firebase AI error occurred. Please try again.");
  }
}


class InvalidApiKeyAppException extends FirebaseAIAppException {
  InvalidApiKeyAppException({
    super.code,
    required super.message
  });
}


class ServerAppException extends FirebaseAIAppException {
  ServerAppException({
    super.code,
    required super.message
  });
}


class UnsupportedUserLocationAppException extends FirebaseAIAppException {
  UnsupportedUserLocationAppException({
    super.code,
    required super.message
  });
}

class QuotaExceededAppException extends FirebaseAIAppException {
  QuotaExceededAppException({
    super.code,
    required super.message
  });
}


class ServiceApiNotEnabledAppException extends FirebaseAIAppException {
  ServiceApiNotEnabledAppException({
    super.code,
    required super.message
  });
}