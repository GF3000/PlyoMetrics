import 'package:plyometrics/core/localized_number_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses localized decimal separators', () {
    expect(parseLocalizedPositiveDouble('75.5', 'en'), 75.5);
    expect(parseLocalizedPositiveDouble('75,5', 'es'), 75.5);
  });

  test('rejects empty, non-numeric and non-positive values', () {
    expect(parseLocalizedPositiveDouble('', 'en'), isNull);
    expect(parseLocalizedPositiveDouble('abc', 'en'), isNull);
    expect(parseLocalizedPositiveDouble('0', 'en'), isNull);
    expect(parseLocalizedPositiveDouble('-2', 'en'), isNull);
  });

  test('rejects a decimal separator from another locale', () {
    expect(parseLocalizedPositiveDouble('75,5', 'en'), isNull);
    expect(parseLocalizedPositiveDouble('75.5', 'es'), isNull);
  });
}
