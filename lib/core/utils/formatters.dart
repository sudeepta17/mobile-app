import 'package:intl/intl.dart';

abstract class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String currency(num amount) {
    return _currencyFormatter.format(amount);
  }

  static String dateShort(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String dateFull(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String parseAndFormatDate(String? dateStr, {String fallback = 'N/A'}) {
    if (dateStr == null || dateStr.isEmpty) return fallback;
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  static String timeString(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
}

