// lib/core/session/day_session_model.dart

/// يمثل جلسة يوم واحد (تاريخ + عناصر/أنشطة مرتبطة بالجلسة).
class DaySessionModel {
  final DateTime date;
  final List<String> items;

  const DaySessionModel({
    required this.date,
    this.items = const [],
  });

  DaySessionModel copyWith({
    DateTime? date,
    List<String>? items,
  }) {
    return DaySessionModel(
      date: date ?? this.date,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'items': items,
  };

  factory DaySessionModel.fromJson(Map<String, dynamic> json) {
    return DaySessionModel(
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  String toString() => 'DaySessionModel(date: $date, items: $items)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DaySessionModel) return false;
    if (date != other.date) return false;
    if (items.length != other.items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(date, Object.hashAll(items));
}
