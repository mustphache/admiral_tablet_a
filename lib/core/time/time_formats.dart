// lib/core/time/time_formats.dart
class TimeFmt {
  /// معرّف تاريخ yyyy-MM-dd (نستعمله كـ dayId عندما اليوم مغلق)
  static String dayIdToday() =>
      DateTime.now().toIso8601String().split('T').first;
}
