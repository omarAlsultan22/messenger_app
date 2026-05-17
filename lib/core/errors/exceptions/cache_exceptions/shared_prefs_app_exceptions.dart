import '../base/app_exception.dart';
import 'base/cache_app_exceptions.dart';
import 'package:test_app/core/errors/exceptions/base/exception_handler.dart';


class SharedPrefsAppException extends CacheAppException implements ExceptionHandler {
  SharedPrefsAppException({
    super.code,
    super.error,
    super.message,
    super.operation,
    super.statusCode,
  });

  static const String _msgCorruptedFile =
      'Local storage file is corrupted, it will be reinitialized';

  static const String _msgConnectionIssue =
      'Connection issue with storage system';

  static final Map<String, AppException> _errorFactories = {
    'streamcorrupted': SharedPrefsInitException(
      message: _msgCorruptedFile,
      platformCode: 'STREAM_CORRUPTED',
    ),
    'invalid stream header': SharedPrefsInitException(
      message: _msgCorruptedFile,
      platformCode: 'INVALID_STREAM_HEADER',
    ),
    'channel-error': SharedPrefsPlatformException(
      message: _msgConnectionIssue,
      platformCode: 'CHANNEL_ERROR',
    ),
    'unable to establish connection': SharedPrefsPlatformException(
      message: _msgConnectionIssue,
      platformCode: 'CONNECTION_FAILED',
    ),
  };

  @override
  bool canHandle() {
    final errorStr = error.toString().toLowerCase();
    return _errorFactories.containsKey(errorStr);
  }

  @override
  AppException handle() {
    if (canHandle()) {
      final errorStr = error.toString().toLowerCase();
      final exception = _errorFactories[errorStr];
      if (exception != null) {
        return exception;
      }
    }
    return SharedPrefsPlatformException(
      message: error.message ?? 'Local storage platform error',
      platformCode: code,
    );
  }
}


class SharedPrefsInitException extends SharedPrefsAppException {
  final String? platformCode;

  SharedPrefsInitException({
    super.message,
    this.platformCode,
    super.code = 'SHARED_PREFS_INIT_ERROR',
  });
}


class SharedPrefsPlatformException extends SharedPrefsAppException {
  final String? platformCode;

  SharedPrefsPlatformException({
    super.message,
    this.platformCode,
    super.code = 'SHARED_PREFS_PLATFORM_ERROR',
  });
}


class SharedPrefsOperationException extends SharedPrefsAppException {
  final String? key;

  SharedPrefsOperationException({
    required super.message,
    this.key,
    super.operation,
    super.code = 'SHARED_PREFS_OPERATION_ERROR',
  });
}


class SharedPrefsCastException extends SharedPrefsAppException {
  final String? key;
  final String? expectedType;

  SharedPrefsCastException({
    super.message,
    this.key,
    this.expectedType,
    super.code = 'SHARED_PREFS_CAST_ERROR',
  });
}