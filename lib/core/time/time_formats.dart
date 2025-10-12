// lib/core/time/time_formats.dart
class TimeFmt {
  static String dayIdToday() =>
      DateTime.now().toIso8601String().split('T').first; // yyyy-MM-dd
}
