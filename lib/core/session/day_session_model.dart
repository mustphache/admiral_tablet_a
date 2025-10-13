import 'package:admiral_tablet_a/data/models/day_session_model.dart';

// نموذج الحالة اليومية (يحوي دوال فتح/غلق اليوم)
class DaySessionState extends DaySessionModel {
  DaySessionState({
    required super.id,
    required super.openedAt,
    super.closedAt,
    required super.openedNow,
    super.capital,
  });

  bool get closed => closedAt != null;

  static DaySessionState fromMap(Map<String, dynamic> map) {
    return DaySessionState(
      id: map['id'] as String,
      openedAt: DateTime.parse(map['openedAt']),
      closedAt: map['closedAt'] == null
          ? null
          : DateTime.parse(map['closedAt']),
      openedNow: map['openedNow'] as bool,
      capital: (map['capital'] as num?)?.toDouble(),
    );
  }
}
