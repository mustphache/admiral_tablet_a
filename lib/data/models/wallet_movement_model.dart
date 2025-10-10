import 'dart:convert';

enum WalletType { open, purchase, expense, refund, adjust ,close , }

class WalletMovementModel {
  final String id;          // ex: 2025-10-06T09:12:22.123Z
  final String dayId;       // نفس id تاع الجلسة (YYYY-MM-DD)
  final WalletType type;
  final double amount;      // موجب = يدخل للمحفظة، سالب = يخرج
  final String? note;

  WalletMovementModel({
    required this.id,
    required this.dayId,
    required this.type,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayId': dayId,
    'type': type.name,
    'amount': amount,
    'note': note,
  };

  factory WalletMovementModel.fromMap(Map<String, dynamic> m) =>
      WalletMovementModel(
        id: m['id'] as String,
        dayId: m['dayId'] as String,
        type: WalletType.values.firstWhere((e) => e.name == m['type']),
        amount: (m['amount'] as num).toDouble(),
        note: m['note'] as String?,
      );

  String toJson() => jsonEncode(toMap());
  factory WalletMovementModel.fromJson(String s) =>
      WalletMovementModel.fromMap(jsonDecode(s));
}
