import 'dart:io';
import 'dart:async';
import 'package:firebase_ai/firebase_ai.dart';
import '../exceptions/base/app_exception.dart';
import '../exceptions/client_app_exception.dart';
import '../exceptions/validation_exception.dart';
import '../exceptions/components_exception.dart';
import '../exceptions/network_app_exception.dart';
import '../exceptions/firebase_app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/network/connectivity_service.dart';
import '../exceptions/shared_prefs_app_exceptions.dart';
import 'package:test_app/core/errors/exceptions/firebase_ai_app_exception.dart';


class ExceptionMapper {
  final dynamic error;

  ExceptionMapper({required this.error});

  static final _connectivityService = ConnectivityService();
  static const String _msgServerError = 'Cannot reach the server';

  static final Map<String, AppException> _networkPatterns = {
    'socket': NetworkAppException(),
    'network': NetworkAppException(),
    'timeout': NetworkAppException(),
    'connection': NetworkAppException(),
    'dns': NetworkAppException(message: _msgServerError),
    'host': NetworkAppException(message: _msgServerError),
    'unable to resolve': NetworkAppException(message: _msgServerError),
  };

  static final Map<Object, AppException Function(dynamic)> _typePatterns = {
    ValidationException: (error) => error,

    ComponentsException: (error) => error,

    SharedPrefsAppException: (error) => error,

    NetworkAppException: (error) => error,

    FirebaseException: (error) {
      final firebaseException = FirebaseAppException(
        message: (error as FirebaseException).message ?? 'Error in Firebase',
        error: error,
      );
      return firebaseException.handle();
    },
    FirebaseAIException: (error) {
      final firebaseException = FirebaseAIAppException(
        message: (error as FirebaseAIException).message,
        error: error,
      );
      return firebaseException.handle();
    },
    SocketException: (_) =>
        NetworkAppException(
          connectivityService: _connectivityService,
        ),
    TimeoutException: (_) =>
        NetworkAppException(
          message: 'Timeout expired, please try again later',
          connectivityService: _connectivityService,
        ),
    FormatException: (_) =>
        ClientAppException(
          message: 'Invalid data format',
        ),
  };

  Iterable<String> get keys => _networkPatterns.keys;

  bool isKey(dynamic error) => _typePatterns.containsKey(error);

  AppException? mapByTypePattern() {
    return _typePatterns[error]!(error);
  }

  AppException? mapByStringPattern() {
    return _networkPatterns[error.toString().toLowerCase()];
  }
}