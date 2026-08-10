import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(amount);
  }

  static String date(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatter.format(date);
  }

  static String dateTime(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return formatter.format(date);
  }
}
