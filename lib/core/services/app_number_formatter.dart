import 'package:intl/intl.dart';

class NumberFormatService {
  /// Format number with thousand separators
  static String formatWithComma(num value) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value);
  }

  /// Format number with currency (default USD)
  static String formatCurrency(num value, {String locale = 'en_US', String symbol = '\$'}) {
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(value);
  }
  
  /// Format number as compact (1K, 1M, etc.)
  static String formatCompact(num value, {String locale = 'en_US'}) {
    final formatter = NumberFormat.compact(locale: locale);
    return formatter.format(value);
  }

  /// Format number as compact with one decimal (831.2M)
  static String formatCompactWithDecimal(num value, {String locale = 'en_US', int decimalDigits = 1}) {
    final formatter = NumberFormat.compact(locale: locale)
      ..maximumFractionDigits = decimalDigits
      ..minimumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  /// Format number as percentage (0.85 -> 85%)
  static String formatPercent(double value, {int decimalDigits = 0}) {
    final formatter = NumberFormat.percentPattern()
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  static String formatDuration(String timeString) {
    try {
      // Split time string
      final parts = timeString.split(':');
      if (parts.length != 3) {
        return timeString; // Return original if invalid format
      }

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);

      // Build formatted string
      List<String> components = [];

      if (hours > 0) {
        components.add('$hours hr');
      }
      if (minutes > 0) {
        components.add('$minutes min');
      }
      if (seconds > 0) {
        components.add('$seconds sec');
      }

      // If all are zero
      if (components.isEmpty) {
        return '0 sec';
      }

      return components.join(' ');
    } catch (e) {
      return timeString; // Return original if parsing fails
    }
  }

  static String formatDate(String isoDate, {String format = 'MMM dd, yyyy'}) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat(format).format(date);
    } catch (e) {
      return isoDate; // Return original if parsing fails
    }
  }
}
