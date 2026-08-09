import 'base/app_exception.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/errors/exceptions/base/exception_handler.dart';


class FirebaseAIAppException extends AppException implements ExceptionHandler {
  FirebaseAIAppException({
    super.code,
    super.error,
    super.message
  });

  static final Map<Object, AppException> _errorFactories = {

    InvalidApiKey: InvalidApiKeyAppException(
        message: 'Invalid API key. Please check your Firebase configuration and ensure the API key is correct.'
    ),
    ServerException: ServerAppException(
        message: 'Server error occurred. Please try again later. If the problem persists, contact support.'
    ),
    UnsupportedUserLocation: UnsupportedUserLocationAppException(
        message: 'Your location is not supported for this service. Please use a supported region or contact support.'
    ),

    QuotaExceeded: QuotaExceededAppException(
        message: 'You have exceeded your daily quota. Please wait until midnight (Pacific Time) for the quota to reset, or upgrade your plan.'
    ),
    ServiceApiNotEnabled: ServiceApiNotEnabledAppException(
        message: 'Gemini API is not enabled. Please enable the Gemini Developer API in your Firebase project settings.'
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