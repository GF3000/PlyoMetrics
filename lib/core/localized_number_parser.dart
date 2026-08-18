import 'package:intl/intl.dart';

double? parseLocalizedPositiveDouble(String input, String localeName) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final decimalSeparator = NumberFormat.decimalPattern(
    localeName,
  ).symbols.DECIMAL_SEP;
  final unsupportedSeparator = decimalSeparator == ',' ? '.' : ',';
  if (trimmed.contains(unsupportedSeparator)) return null;

  final normalized = trimmed.replaceAll(decimalSeparator, '.');
  final parsed = double.tryParse(normalized);
  return parsed != null && parsed.isFinite && parsed > 0 ? parsed : null;
}
