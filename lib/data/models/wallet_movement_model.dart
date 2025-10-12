import 'dart:convert';

enum WalletType { open, purchase, expense, refund, adjust, close }

class WalletMovementModel {
  final String id;
  final String dayId;
  final WalletType type;
  final double amount;
  final String? note;

  /// يُحفظ وقت الإنشاء بدقة الميلي ثانية (UTC).
  final DateTime createdAt;

  WalletMovementModel({
    required this.id,
    required this.dayId,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  WalletMovementModel copyWith({
    String? id,
    String? dayId,
    WalletType? type,
    double? amount,
    String? note,
    DateTime? createdAt,
  }) {
    return WalletMovementModel(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayId': dayId,
    'type': type.name,
    'amount': amount,
    'note': note,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory WalletMovementModel.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    final created = (createdAtRaw is String && createdAtRaw.isNotEmpty)
        ? DateTime.parse(createdAtRaw).toUtc()
        : DateTime.now().toUtc();

    return WalletMovementModel(
      id: map['id']?.toString() ?? '',
      dayId: map['dayId']?.toString() ?? '',
      type: _typeFrom(map['type']),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      note: map['note']?.toString(),
      createdAt: created,
    );
  }

  String toJson() => json.encode(toMap());
  factory WalletMovementModel.fromJson(String src) =>
      WalletMovementModel.fromMap(json.decode(src) as Map<String, dynamic>);

  static WalletType _typeFrom(dynamic v) {
    final s = v?.toString() ?? '';
    return WalletType.values.firstWhere(
          (e) => e.name == s,
      orElse: () => WalletType.adjust,
    );
  }
}
