import '../base/app_exception.dart';
import '../base/exception_handler.dart';
import 'base/cache_app_exceptions.dart';


class HiveAppExceptions extends CacheAppException implements ExceptionHandler {
  HiveAppExceptions({
    super.code,
    super.error,
    super.operation
  });

  static const String _msgDatabaseNotExist = 'Database does not exist';
  static const String _msgFileSystemError = 'An error occurred in the database file';
  static const String _msgEncryptionError = 'Error in database encryption/decryption';
  static const String _msgNotInitialized = 'Database has not been initialized correctly';

  static String? _extractBoxName(String errorString) {
    // Create the Regex separately and safely
    const pattern = r'box\s+["'']?(\w+)["'']?';
    final regex = RegExp(pattern);
    final match = regex.firstMatch(errorString);
    return match?.group(1);
  }

  static final Map<String,
      AppException Function(String errorMsg)> _errorFactories = {
    'box has already been closed': (msg) =>
        HiveBoxException(
          error: 'Attempting to access a closed database',
          code: 'HIVE_BOX_CLOSED',
        ),
    'box not found': (msg) =>
        HiveBoxException(
          error: _msgDatabaseNotExist,
          code: 'HIVE_BOX_NOT_FOUND',
        ),
    'box doesn\'t exist': (msg) =>
        HiveBoxException(
          error: _msgDatabaseNotExist,
          code: 'HIVE_BOX_NOT_FOUND',
        ),
    'null': (msg) =>
        HiveBoxException(
          error: _msgNotInitialized,
          code: 'HIVE_BOX_NULL',
        ),
    'box': (msg) =>
        HiveBoxException(
          error: _msgNotInitialized,
          code: 'HIVE_BOX_NULL',
        ),
    'openbox': (msg) =>
        HiveOpenBoxException(
          boxName: _extractBoxName(msg) ?? 'unknown',
          error: 'Failed to open database: $msg',
        ),
    'failed to open': (msg) =>
        HiveOpenBoxException(
          boxName: _extractBoxName(msg) ?? 'unknown',
          error: 'Failed to open database: $msg',
        ),
    'filesystemexception': (msg) =>
        HiveOperationException(
          error: _msgFileSystemError,
          operation: 'file_system',
        ),
    'file closed': (msg) =>
        HiveOperationException(
          error: _msgFileSystemError,
          operation: 'file_system',
        ),
    'compaction': (msg) =>
        HiveOperationException(
          error: 'An error occurred while compacting the database',
          operation: 'compaction',
        ),
    'encryption': (msg) =>
        HiveOperationException(
          error: _msgEncryptionError,
          operation: 'encryption',
        ),
    'decryption': (msg) =>
        HiveOperationException(
          error: _msgEncryptionError,
          operation: 'encryption',
        ),
    'put': (msg) =>
        HiveOperationException(
          error: 'Failed to save data to database',
          operation: 'put',
        ),
    'get': (msg) =>
        HiveOperationException(
          error: 'Failed to read data from database',
          operation: 'get',
        ),
    'delete': (msg) =>
        HiveOperationException(
          error: 'Failed to delete data from database',
          operation: 'delete',
        ),
  };

  @override
  bool canHandle() {
    final errorStr = error.toString().toLowerCase();
    return _errorFactories.containsKey(errorStr);
  }

  @override
  AppException handle() {
    final errorStr = error.toString().toLowerCase();
    if (canHandle()) {
      return _errorFactories[errorStr]!(errorStr);
    }
    return HiveOperationException(
      error: error.message ?? 'Local storage error: ${error.toString()}',
    );
  }
}


class HiveCacheException extends HiveAppExceptions {
  HiveCacheException({
    required super.error,
    super.code = 'HIVE_ERROR',
    super.operation,
  });
}


class HiveBoxException extends HiveAppExceptions {
  final String? boxName;

  HiveBoxException({
    required super.error,
    this.boxName,
    super.code = 'HIVE_BOX_ERROR',
  });
}


class HiveOpenBoxException extends HiveAppExceptions {
  final String boxName;
  final String? path;

  HiveOpenBoxException({
    required this.boxName,
    required super.error,
    this.path,
    super.code = 'HIVE_OPEN_BOX_ERROR',
  });
}


class HiveCloseBoxException extends HiveAppExceptions {
  HiveCloseBoxException({
    super.error,
    super.code = 'HIVE_CLOSE_BOX_ERROR',
  });
}


class HiveOperationException extends HiveAppExceptions {
  final String? boxName;
  final dynamic key;

  HiveOperationException({
    required super.error,
    this.boxName,
    this.key,
    super.operation,
    super.code = 'HIVE_OPERATION_ERROR',
  });
}


class HiveSaveException extends HiveAppExceptions {
  HiveSaveException({
    required super.error,
    super.operation = 'save',
    super.code = 'HIVE_SAVE_ERROR',
  });
}


class HiveReadException extends HiveAppExceptions {
  HiveReadException({
    required super.error,
    super.operation = 'read',
    super.code = 'HIVE_READ_ERROR',
  });
}


class HiveDeleteException extends HiveAppExceptions {
  HiveDeleteException({
    required super.error,
    super.operation = 'delete',
    super.code = 'HIVE_DELETE_ERROR',
  });
}


class HiveClearException extends HiveAppExceptions {
  HiveClearException({
    required super.error,
    super.operation = 'clear',
    super.code = 'HIVE_CLEAR_ERROR',
  });
}