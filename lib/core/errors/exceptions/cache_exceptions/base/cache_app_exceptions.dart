import '../../base/app_exception.dart';


abstract class CacheAppException extends AppException {
  final String? operation;

  const CacheAppException({
    super.code,
    super.error,
    super.message,
    this.operation,
    super.statusCode,
  });
}
