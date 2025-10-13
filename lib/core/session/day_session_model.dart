// lib/core/session/day_session_model.dart
// النموذج الكامل لحالة اليوم كما كان قبل الحذف

class DaySessionState {
  final String id; // تاريخ اليوم بصيغة YYYY-MM-DD
  final DateTime openedAt;
  final DateTime? closedAt;
  final bool openedNow;
  final double? capital;

  DaySessionState({
    required this.id,
    required this.openedAt,
    this.closedAt,
    required this.openedNow,
    this.capital,
  });

  bool get closed => closedAt != null;

  DaySessionState copyWith({
    String? id,
    DateTime? openedAt,
    DateTime? closedAt,
    bool? openedNow,
    double? capital,
  }) {
    return DaySessionState(
      id: id ?? this.id,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openedNow: openedNow ?? this.openedNow,
      capital: capital ?? this.capital,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'openedAt': openedAt.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
    'openedNow': openedNow,
    'capital': capital,
  };

  static DaySessionState fromMap(Map<String, dynamic> map) {
    return DaySessionState(
      id: map['id'] as String,
      openedAt: DateTime.parse(map['openedAt'] as String),
      closedAt: map['closedAt'] != null
          ? DateTime.parse(map['closedAt'] as String)
          : null,
      openedNow: map['openedNow'] as bool? ?? false,
      capital: (map['capital'] as num?)?.toDouble(),
    );
  }
}
