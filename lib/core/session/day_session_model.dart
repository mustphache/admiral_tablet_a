import 'dart:convert';

/// الحالة المتوقعة في بقية المشروع (dayId/createdAt/openedAt/closedAt)
class DaySessionState {
  final String dayId;
  final DateTime createdAt;
  final DateTime openedAt;
  final DateTime? closedAt;

  const DaySessionState({
    required this.dayId,
    required this.createdAt,
    required this.openedAt,
    this.closedAt,
  });

  bool get isOpen => closedAt == null;
  bool get isClosed => !isOpen;

  DaySessionState copyWith({
    String? dayId,
    DateTime? createdAt,
    DateTime? openedAt,
    DateTime? closedAt,
  }) {
    return DaySessionState(
      dayId: dayId ?? this.dayId,
      createdAt: createdAt ?? this.createdAt,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'dayId': dayId,
    'createdAt': createdAt.toIso8601String(),
    'openedAt': openedAt.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
  };

  factory DaySessionState.fromMap(Map<String, dynamic> m) => DaySessionState(
    dayId: m['dayId'] as String,
    createdAt: DateTime.parse(m['createdAt'] as String),
    openedAt: DateTime.parse(m['openedAt'] as String),
    closedAt: m['closedAt'] == null ? null : DateTime.parse(m['closedAt'] as String),
  );

  String toJson() => jsonEncode(toMap());
  static DaySessionState fromJson(String s) =>
      DaySessionState.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
