import 'base/app_exception.dart';


class ComponentsException extends AppException {
  const ComponentsException({super.error}) : super(
    message: 'The application component initialization process failed.',
    code: 'INITIALIZE_ERROR',
  );
}