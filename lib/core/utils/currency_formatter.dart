import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatGram(double gram) {
    return '${gram.toStringAsFixed(3)} gr';
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    return formatter.format(date);
  }
}
