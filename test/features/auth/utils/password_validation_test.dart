import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/features/auth/utils/validate/password_validation.dart';


void main() {
  group('PasswordValidation.validator', () {
    // ===== null / empty =====
    test('returns "Please enter your password" when value is null', () {
      expect(PasswordValidation.validator(null), 'Please enter your password');
    });

    test('returns "Please enter your password" when value is empty', () {
      expect(PasswordValidation.validator(''), 'Please enter your password');
    });

    // ===== too short =====
    test('rejects password with 7 characters (just below minimum)', () {
      expect(
        PasswordValidation.validator('1234567'),
        'Password must be at least 8 characters',
      );
    });

    test('rejects password with 1 character', () {
      expect(
        PasswordValidation.validator('a'),
        'Password must be at least 8 characters',
      );
    });

    // ===== exactly at minimum =====
    test('accepts password with exactly 8 characters (boundary)', () {
      expect(PasswordValidation.validator('12345678'), isNull);
    });

    // ===== above minimum =====
    test('accepts password with 9+ characters', () {
      expect(PasswordValidation.validator('123456789'), isNull);
    });

    test('accepts long password', () {
      expect(PasswordValidation.validator('a' * 100), isNull);
    });

    // ===== special characters (no restrictions) =====
    test('accepts password with special characters', () {
      expect(PasswordValidation.validator('P@ssw0rd!'), isNull);
    });

    test('accepts password with spaces', () {
      expect(PasswordValidation.validator('pass word'), isNull);
    });
  });
}