import 'dart:convert';

/// نموذج جلسة اليوم (Tablet A)
class DaySessionModel {
  /// معرف الجلسة (عادة yyyy-MM-dd)
  final String id;

  /// السوق / الموقع
  final String market;

  /// رصيد الافتتاح
  final double openingCash;

  /// ملاحظات اختيارية
  final String? notes;

  /// وقت الإنشاء
  final DateTime createdAt;

  /// وقت الإغلاق (null إذا اليوم مفتوح)
  final DateTime? closedAt;

  const DaySessionModel({
    required this.id,
    required this.market,
    required this.openingCash,
    required this.createdAt,
    this.notes,
    this.closedAt,
  });

  /// تاريخ اليوم بصيغة ISO yyyy-MM-dd (يُستعمل كـ id افتراضي)
  static String todayISO() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  bool get isOpen => closedAt == null;

  DaySessionModel copyWith({
    String? id,
    String? market,
    double? openingCash,
    String? notes,
    DateTime? createdAt,
    DateTime? closedAt,
  }) {
    return DaySessionModel(
      id: id ?? this.id,
      market: market ?? this.market,
      openingCash: openingCash ?? this.openingCash,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'market': market,
    'openingCash': openingCash,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
  };

  factory DaySessionModel.fromMap(Map<String, dynamic> map) {
    return DaySessionModel(
      id: map['id'] as String,
      market: map['market'] as String? ?? '',
      openingCash: (map['openingCash'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      closedAt:
      (map['closedAt'] as String?) != null ? DateTime.parse(map['closedAt']) : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  static DaySessionModel fromJson(String raw) =>
      DaySessionModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
}
