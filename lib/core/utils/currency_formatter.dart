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
    if (amount >= 1000) {
      // Convert to kg
      final kg = amount / 1000;
      final display = kg == kg.truncateToDouble()
          ? kg.toStringAsFixed(0)
          : kg.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      return '$display kg';
    } else {
      // Display in gram
      final display = amount == amount.truncateToDouble()
          ? amount.toStringAsFixed(0)
          : amount.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      return '$display gr';
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}
