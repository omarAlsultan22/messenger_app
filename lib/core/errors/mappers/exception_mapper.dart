import 'dart:io';
import 'dart:async';
import 'package:firebase_ai/firebase_ai.dart';
import '../exceptions/base/app_exception.dart';
import '../exceptions/client_app_exception.dart';
import '../exceptions/network_app_exception.dart';
import '../exceptions/firebase_app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/network/connectivity_service.dart';
import 'package:test_app/core/constants/app_strings.dart';
import 'package:test_app/core/errors/exceptions/firebase_ai_app_exception.dart';


class ExceptionMapper {
  final dynamic error;

  ExceptionMapper({required this.error});

  static final _connectivityService = ConnectivityService();
  static const _noInternetMessage = AppStrings.noInternetMessage;
  static const String _msgServerError = 'Cannot reach the server';

  static final Map<String, AppException> _networkPatterns = {
    'socket': NetworkAppException(message: _noInternetMessage),
    'connection': NetworkAppException(message: _noInternetMessage),
    'network': NetworkAppException(message: _noInternetMessage),
    'timeout': NetworkAppException(message: _noInternetMessage),
    'host': NetworkAppException(message: _msgServerError),
    'dns': NetworkAppException(message: _msgServerError),
    'unable to resolve': NetworkAppException(message: _msgServerError),
  };

  static final Map<Object, AppException Function(dynamic)> _typePatterns = {
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
    SocketException: (error) =>
        NetworkAppException(
          message: 'No Internet Connection',
          connectivityService: _connectivityService,
        ),
    TimeoutException: (error) =>
        NetworkAppException(
          message: 'Timeout expired, please try again later',
          connectivityService: _connectivityService,
        ),
    FormatException: (error) =>
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