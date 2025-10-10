import 'dart:convert';

String formatNumber(num v, {int fractionDigits = 2}) => v.toStringAsFixed(fractionDigits);

String safeEncode(Map<String, dynamic> m) => jsonEncode(m);

Map<String, dynamic> safeDecode(String? s) {
  if (s == null || s.isEmpty) return {};
  try {
    final v = jsonDecode(s);
    return v is Map<String, dynamic> ? v : <String, dynamic>{};
  } catch (_) {
    return {};
  }
}

String todayISO([DateTime? now]) {
  final d = now ?? DateTime.now();
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final da = d.day.toString().padLeft(2, '0');
  return '$y-$m-$da';
}
