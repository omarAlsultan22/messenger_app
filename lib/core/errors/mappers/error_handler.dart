import '../exceptions/cache_exceptions/shared_prefs_app_exceptions.dart';
import '../exceptions/unknown_app_exception.dart';
import '../exceptions/base/app_exception.dart';
import 'package:flutter/services.dart';
import 'exception_mapper.dart';


class ErrorHandler {
  final dynamic error;
  final StackTrace stackTrace;
  late final ExceptionMapper _exceptionMapper;

  ErrorHandler({
    required this.error,
    required this.stackTrace
  }) {
    _exceptionMapper = ExceptionMapper(error: error);
  }

  // ==================== Main Function ====================

  AppException handleException() {
    // Log the error (for analytics)
    _logError(error, stackTrace);

    return _mapByTypePattern() ??
        _mapByStringPattern() ??
        _mapBySharedPrefError() ??
        UnknownAppException(message: error.toString());
  }

  // ==================== Helper Functions for Checking ====================

  bool _isSharedPrefsError() {
    final errorStr = error.toString().toLowerCase();
    return error is PlatformException &&
        (errorStr.contains('shared_preferences') ||
            errorStr.contains('sharedpreferences')) ||
        error is MissingPluginException &&
            errorStr.contains('shared_preferences') ||
        errorStr.contains('sharedpreferences') ||
        errorStr.contains('preferences') && errorStr.contains('instance');
  }

  AppException? _mapByTypePattern() {
    if (_exceptionMapper.isKey(error)) {
      return _exceptionMapper.mapByTypePattern();
    }
    return null;
  }

  AppException? _mapByStringPattern() {
    for (var key in _exceptionMapper.keys) {
      if (error.toString().contains(key)) {
        return _exceptionMapper.mapByStringPattern();
      }
    }
    return null;
  }

  AppException? _mapBySharedPrefError() {
    if (_isSharedPrefsError()) {
      final prefsException = SharedPrefsAppException(
        error: error,
        code: (error as PlatformException).code,
      );
      return prefsException.handle();
    }
    return null;
  }

  void _logError(dynamic error, StackTrace? stackTrace) {
    // For tracking and analytics
    print('════════════════════════════════════════');
    print('❌ Error caught: ${error.runtimeType}');
    print('Message: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
    print('════════════════════════════════════════');
  }
}
