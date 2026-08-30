import '../exceptions/unknown_app_exception.dart';
import '../exceptions/base/app_exception.dart';
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
        UnknownAppException(message: error.toString());
  }

  // ==================== Helper Functions for Checking ====================

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

  void _logError(dynamic error, StackTrace? stackTrace) {
    // For tracking and analytics
    print('════════════════════════════════════════');
    print('❌ Error caught: ${error.runtimeType}');
    print('Message: ${error.toString()}');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
    print('════════════════════════════════════════');
  }
}
