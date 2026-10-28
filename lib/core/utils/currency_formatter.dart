import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,###', 'id_ID');

  /// Formats amount into `Rp150.000` or `Rp 150.000`
  static String format(double amount, {bool withSpace = false}) {
    final formatted = _idrFormat.format(amount);
    if (!withSpace) {
      return formatted.replaceAll('Rp ', 'Rp');
    }
    return formatted;
  }

  /// Formats number only: `150.000`
  static String formatNumber(double amount) {
    return _numberFormat.format(amount.round());
  }

  /// Parses string like "Rp 150.000" or "150000" into double
  static double parse(String text) {
    if (text.isEmpty) return 0.0;
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
