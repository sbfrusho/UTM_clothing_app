import '../config/app_config.dart';

abstract final class Formatters {
  static String price(double amount) =>
      '${AppConfig.currencySymbol} ${amount.toStringAsFixed(2)}';

  static String date(DateTime? date) {
    if (date == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  static String dateTime(DateTime? date) {
    if (date == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${Formatters.date(date)} ${two(date.hour)}:${two(date.minute)}';
  }
}
