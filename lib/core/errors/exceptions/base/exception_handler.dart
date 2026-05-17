import 'app_exception.dart';


abstract class ExceptionHandler {
  bool canHandle();
  AppException handle();
}
