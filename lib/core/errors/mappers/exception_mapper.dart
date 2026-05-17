import 'dart:io';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import '../exceptions/base/app_exception.dart';
import '../exceptions/client_app_exception.dart';
import '../exceptions/network_app_exception.dart';
import '../exceptions/firebase_app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../exceptions/cache_exceptions/hive_app_exceptions.dart';
import '../exceptions/cache_exceptions/shared_prefs_app_exceptions.dart';
import '../../../features/conversation/domain/services/connectivity_service/connectivity_service.dart';


class ExceptionMapper {
  final dynamic error;

  ExceptionMapper({required this.error});

  static final connectivityService = ConnectivityService();
  static const String _msgCastError = 'Error in stored data type';
  static const String _msgWriteError = 'Failed to save data to local storage';
  static const String _msgReadError = 'Failed to read data from local storage';
  static const String _msgInitError = 'Local storage has not been initialized correctly';

  static final Map<String, AppException> _stringPatterns = {
    '_casterror': SharedPrefsCastException(
      message: _msgCastError,
    ),
    'null check operator': SharedPrefsCastException(
      message: _msgCastError,
    ),
    'getinstance': SharedPrefsInitException(
      message: _msgInitError,
    ),
    'not initialized': SharedPrefsInitException(
      message: _msgInitError,
    ),
    'binding has not been initialized': SharedPrefsInitException(
      message: _msgInitError,
    ),
    'read': SharedPrefsOperationException(
      message: _msgReadError,
      operation: 'read',
    ),
    'get': SharedPrefsOperationException(
      message: _msgReadError,
      operation: 'read',
    ),
    'write': SharedPrefsOperationException(
      message: _msgWriteError,
      operation: 'write',
    ),
    'set': SharedPrefsOperationException(
      message: _msgWriteError,
      operation: 'write',
    ),
    'save': SharedPrefsOperationException(
      message: _msgWriteError,
      operation: 'write',
    ),
  };

  static final Map<Type, AppException Function(dynamic)> _typePatterns = {
    HiveError: (error) {
      final hiveException = HiveAppExceptions(error: error);
      return hiveException.handle();
    },
    FirebaseException: (error) {
      final firebaseException = FirebaseAppException(
        message: (error as FirebaseException).message ?? 'خطأ في Firebase',
        error: error,
      );
      return firebaseException.handle();
    },
    SocketException: (error) =>
        NetworkAppException(
          message: 'No Internet Connection',
          connectivityService: connectivityService,
        ),
    TimeoutException: (error) =>
        NetworkAppException(
          message: 'Timeout expired, please try again later',
          connectivityService: connectivityService,
        ),
    FormatException: (error) =>
        ClientAppException(
          message: 'Invalid data format',
        ),
  };

  Iterable<String> get keys => _stringPatterns.keys;

  bool isKey(dynamic error) => _typePatterns.containsKey(error);

  bool isSharedPrefsError() {
    final errorStr = error.toString().toLowerCase();
    return error is PlatformException &&
        (errorStr.contains('shared_preferences') ||
            errorStr.contains('sharedpreferences')) ||
        error is MissingPluginException &&
            errorStr.contains('shared_preferences') ||
        errorStr.contains('sharedpreferences') ||
        errorStr.contains('preferences') && errorStr.contains('instance');
  }

  AppException? mapByTypePattern() {
    final exception = _stringPatterns[error];
    if (exception != null) {
      return exception;
    }
    return null;
  }

  AppException? mapByStringPattern() {
    final exception = _typePatterns[error]!(error);
    return exception;
  }
}