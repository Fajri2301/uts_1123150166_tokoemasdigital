import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat('#,###', 'id_ID');

  static String format(double amount, {bool withSymbol = true}) {
    final formatted = _formatter.format(amount.abs().round());
    return withSymbol ? 'Rp$formatted' : formatted;
  }

  static String formatInt(int amount, {bool withSymbol = true}) {
    return format(amount.toDouble(), withSymbol: withSymbol);
  }

  static String maskBalance() => 'Rp • • • • • •';

  static String formatRupiah(double amount) {
    return 'Rp${_formatter.format(amount)}';
  }

  static String formatGram(double amount) {
    return '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} gr';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}
