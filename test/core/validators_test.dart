import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts normal addresses, trimmed', () {
      expect(Validators.email('a@b.co'), isNull);
      expect(Validators.email('  name.surname@shop.com.my '), isNull);
    });
    test('rejects empty and malformed', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('no-at-sign.com'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('needs 8+ characters with letters and numbers', () {
      expect(Validators.password('abc12345'), isNull);
      expect(Validators.password('Abc1'), 'Use at least 8 characters');
      expect(Validators.password('abcdefgh'), 'Use letters and numbers');
      expect(Validators.password('12345678'), 'Use letters and numbers');
      expect(Validators.password(''), 'Password is required');
    });
  });

  group('Validators.phone', () {
    test('accepts local and international formats', () {
      expect(Validators.phone('+60 12-345 6789'), isNull);
      expect(Validators.phone('0123456789'), isNull);
    });
    test('rejects letters and too-short numbers', () {
      expect(Validators.phone('12ab'), isNotNull);
      expect(Validators.phone('123'), isNotNull);
    });
  });
}
