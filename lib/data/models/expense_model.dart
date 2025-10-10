import 'dart:convert';

/// حركة مصروف تابعة لجلسة يوم معينة
class ExpenseModel {
  /// ملاحظة: نجعل id و sessionId غير نهائيين لتفادي خطأ
  /// "id can't be used as a setter because it's final" داخل الـ controllers.
  String? id;
  String sessionId;

  /// نوع/تصنيف المصروف
  final String kind;

  /// المبلغ
  final double amount;

  /// ملاحظة
  final String? note;

  /// وقت الإدخال
  final DateTime timestamp;

  ExpenseModel({
    this.id,
    required this.sessionId,
    required this.kind,
    required this.amount,
    this.note,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  ExpenseModel copyWith({
    String? id,
    String? sessionId,
    String? kind,
    double? amount,
    String? note,
    DateTime? timestamp,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'sessionId': sessionId,
    'kind': kind,
    'amount': amount,
    'note': note,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String?,
      sessionId: map['sessionId'] as String? ?? '',
      kind: map['kind'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      note: map['note'] as String?,
      timestamp: (map['timestamp'] as String?) != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  static ExpenseModel fromJson(String raw) =>
      ExpenseModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
}
