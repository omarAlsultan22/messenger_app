import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/shared/utils/validate_input.dart';


void main() {
  group('ValidateInput.validator', () {
    test('returns error message when value is null', () {
      final result = ValidateInput.validator(value: null, text: 'Name');

      expect(result, 'Please Enter Your Name');
    });

    test('returns error message when value is empty', () {
      final result = ValidateInput.validator(value: '', text: 'Email');

      expect(result, 'Please Enter Your Email');
    });

    test('returns null when value is not empty', () {
      final result = ValidateInput.validator(value: 'Ali', text: 'Name');

      expect(result, isNull);
    });

    test('includes the text parameter in the error message', () {
      final result = ValidateInput.validator(value: '', text: 'Password');

      expect(result, contains('Password'));
    });

    test('returns null for whitespace-only string (documents behavior)', () {
      // '   ' ليست فارغة (isEmpty == false) → null
      final result = ValidateInput.validator(value: '   ', text: 'Name');

      expect(result, isNull);
    });
  });
}