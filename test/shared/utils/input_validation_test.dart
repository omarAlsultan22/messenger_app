import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/shared/utils/input_validation.dart';


void main() {
  group('InputValidation.validator', () {
    test('returns error message when value is null', () {
      final result = InputValidation.validator(value: null, text: 'Name');

      expect(result, 'Please Enter Your Name');
    });

    test('returns error message when value is empty', () {
      final result = InputValidation.validator(value: '', text: 'Email');

      expect(result, 'Please Enter Your Email');
    });

    test('returns null when value is not empty', () {
      final result = InputValidation.validator(value: 'Ali', text: 'Name');

      expect(result, isNull);
    });

    test('includes the text parameter in the error message', () {
      final result = InputValidation.validator(value: '', text: 'Password');

      expect(result, contains('Password'));
    });

    test('returns null for whitespace-only string (documents behavior)', () {
      // '   ' ليست فارغة (isEmpty == false) → null
      final result = InputValidation.validator(value: '   ', text: 'Name');

      expect(result, isNull);
    });
  });
}