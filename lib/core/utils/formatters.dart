import '../config/app_config.dart';

abstract final class Formatters {
  /// `Tk 1,290`, or `Tk 1,290.50` when there are paisa.
  static String price(double amount) {
    final fixed = amount.abs().toStringAsFixed(2);
    final dot = fixed.indexOf('.');
    final whole = fixed.substring(0, dot);
    final fraction = fixed.substring(dot);
    final grouped = whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final sign = amount < 0 ? '-' : '';
    final tail = fraction == '.00' ? '' : fraction;
    return '$sign${AppConfig.currencySymbol} $grouped$tail';
  }

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
