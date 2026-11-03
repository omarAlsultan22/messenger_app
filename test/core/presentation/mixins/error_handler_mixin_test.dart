import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/errors/exceptions/base/app_exception.dart';
import 'package:test_app/core/presentation/mixins/error_handler_mixin.dart';


class FakeCubit extends Cubit<int> with ErrorHandlerMixin<int> {
  FakeCubit() : super(0);

  void triggerError({
    required Object error,
    required StackTrace stackTrace,
    required int Function(AppException) onError,
  }) {
    handleError(error, stackTrace, onError: onError);
  }
}

void main() {
  late FakeCubit cubit;

  setUp(() {
    cubit = FakeCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('handleError', () {
    test('emits the state returned by onError', () async {
      cubit.triggerError(
        error: Exception('test'),
        stackTrace: StackTrace.current,
        onError: (_) => 42,
      );

      expect(cubit.state, 42);
    });

    test('passes AppException to onError', () async {
      AppException? capturedFailure;

      cubit.triggerError(
        error: Exception('test'),
        stackTrace: StackTrace.current,
        onError: (failure) {
          capturedFailure = failure;
          return 1;
        },
      );

      expect(capturedFailure, isA<AppException>());
    });

    test('emits only once', () async {
      final states = <int>[];
      final sub = cubit.stream.listen(states.add);

      cubit.triggerError(
        error: Exception('e'),
        stackTrace: StackTrace.current,
        onError: (_) => 7,
      );

      await Future<void>.delayed(Duration.zero);
      expect(states, [7]);

      await sub.cancel();
    });

    test('does not emit when onError throws', () async {
      expect(
            () =>
            cubit.triggerError(
              error: Exception('e'),
              stackTrace: StackTrace.current,
              onError: (_) => throw Exception('onError failed'),
            ),
        throwsA(isA<Exception>()),
      );

      expect(cubit.state, 0);
    });
  });
}