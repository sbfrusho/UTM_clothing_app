import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/core/utils/formatters.dart';

void main() {
  test('prices are in Taka with thousands separators', () {
    expect(Formatters.price(0), 'Tk 0');
    expect(Formatters.price(390), 'Tk 390');
    expect(Formatters.price(1290), 'Tk 1,290');
    expect(Formatters.price(1234567.5), 'Tk 1,234,567.50');
    expect(Formatters.price(49.999), 'Tk 50');
    expect(Formatters.price(-1500), '-Tk 1,500');
  });
}
