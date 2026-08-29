

import 'base/app_exception.dart';


class SharedPrefsAppException extends AppException {
  const SharedPrefsAppException({
    super.code,
    super.error,
    super.message,
    super.statusCode,
  });
}

class SharedPrefsInitializeException extends SharedPrefsAppException {
  const SharedPrefsInitializeException({super.error}) : super(
    message: 'SharedPrefs not initialized. Please try again.',
    code: 'SHARED_PREFS_INITIALIZE_ERROR',
  );
}

class SharedPrefsSaveException extends SharedPrefsAppException {
  const SharedPrefsSaveException({super.error}) : super(
    message: 'Failed to save key. Please try again.',
    code: 'SHARED_PREFS_SAVE_ERROR',
  );
}

class SharedPrefsReadException extends SharedPrefsAppException {
  const SharedPrefsReadException({super.error}) : super(
      message: 'Failed to load key. Try again.',
      code: 'SHARED_PREFS_READ_ERROR');
}

class SharedPrefsRemoveException extends SharedPrefsAppException {
  const SharedPrefsRemoveException({super.error}) : super(
    message: 'Failed to remove key. Try again.',
    code: 'SHARED_PREFS_REMOVE_ERROR',
  );
}
