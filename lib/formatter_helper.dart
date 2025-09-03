import 'package:intl/intl.dart';

class FormatterHelper {
  static String formatRp(int price) {
    var formatter = NumberFormat('###,###', 'id');
    return "Rp ${formatter.format((price))}";
  }

  static String formatRpDouble(double price) {
    var formatter = NumberFormat('###,###', 'id');
    return "Rp ${formatter.format((price))}";
  }
}
