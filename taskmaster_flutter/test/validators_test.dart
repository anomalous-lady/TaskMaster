// test/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns error for empty string', () {
        expect(Validators.email(''), isNotNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('missing@domain'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('user@example.com'), isNull);
        expect(Validators.email('test.user+tag@subdomain.org'), isNull);
      });
    });

    group('password', () {
      test('returns error for empty string', () {
        expect(Validators.password(''), isNotNull);
      });

      test('returns error for short password', () {
        expect(Validators.password('12345'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('secret123'), isNull);
      });
    });

    group('taskTitle', () {
      test('returns error for empty title', () {
        expect(Validators.taskTitle(''), isNotNull);
      });

      test('returns error for too short title', () {
        expect(Validators.taskTitle('AB'), isNotNull);
      });

      test('returns null for valid title', () {
        expect(Validators.taskTitle('Design the homepage'), isNull);
      });

      test('returns error for title over 100 characters', () {
        expect(Validators.taskTitle('A' * 101), isNotNull);
      });
    });
  });
}
