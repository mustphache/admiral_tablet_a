// lib/core/money/money.dart
class Money {
  static String fmt(double v) {
    final s = v.toStringAsFixed(2);
    return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }
}
