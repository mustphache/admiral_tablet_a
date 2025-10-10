import 'dart:convert';

class OutboxItemModel {
  final String id;            // معرف فريد (UUID)
  final String kind;          // نوع العملية: 'wallet'، 'purchase'، 'expense'...
  final String dayId;         // معرف جلسة اليوم (YYYY-MM-DD)
  final Map<String, dynamic> payload; // بيانات العملية نفسها
  final DateTime createdAt;   // وقت الإنشاء

  OutboxItemModel({
    required this.id,
    required this.kind,
    required this.dayId,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'kind': kind,
    'dayId': dayId,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OutboxItemModel.fromMap(Map<String, dynamic> map) => OutboxItemModel(
    id: map['id'] as String,
    kind: map['kind'] as String,
    dayId: map['dayId'] as String,
    payload: Map<String, dynamic>.from(map['payload'] as Map),
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  String toJson() => jsonEncode(toMap());

  factory OutboxItemModel.fromJson(String source) =>
      OutboxItemModel.fromMap(jsonDecode(source));
}
