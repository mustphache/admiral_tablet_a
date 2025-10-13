import 'dart:convert';

/// يمثل حالة جلسة اليوم (مفتوحة/مغلقة) مع معلوماتها الأساسية.
class DaySessionState {
  final String dayId;           // بصيغة YYYY-MM-DD مثلاً
  final DateTime createdAt;     // وقت إنشاء الجلسة في الجهاز
  final DateTime openedAt;      // وقت الفتح
  final DateTime? closedAt;     // null إذا مازالت مفتوحة

  const DaySessionState({
    required this.dayId,
    required this.createdAt,
    required this.openedAt,
    this.closedAt,
  });

  /// هل الجلسة مفتوحة؟
  bool get isOpen => closedAt == null;

  /// هل الجلسة مغلقة؟
  bool get isClosed => closedAt != null;

  /// حفاظًا على التوافق مع كود يستدعيها كـ closed()
  bool closed() => isClosed;

  /// حفاظًا على التوافق مع كود يستدعيها كـ openedNow()
  bool openedNow() => isOpen;

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

  factory DaySessionState.fromMap(Map<String, dynamic> map) {
    return DaySessionState(
      dayId: map['dayId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      openedAt: DateTime.parse(map['openedAt'] as String),
      closedAt:
      map['closedAt'] == null ? null : DateTime.parse(map['closedAt'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  /// حفاظًا على التوافق مع كود يستدعي DaySessionState.fromJson(...)
  static DaySessionState fromJson(String source) =>
      DaySessionState.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
