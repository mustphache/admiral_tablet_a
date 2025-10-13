import 'dart:convert';

/// أنواع الحركات في المحفظة.
enum WalletType {
  deposit,   // إيداع
  withdraw,  // سحب
  refund,    // استرجاع (مثلاً من A عند غلق اليوم)
  adjust,    // تسوية/تصحيح
}

WalletType walletTypeFromString(String s) {
  switch (s) {
    case 'deposit':
      return WalletType.deposit;
    case 'withdraw':
      return WalletType.withdraw;
    case 'refund':
      return WalletType.refund;
    case 'adjust':
      return WalletType.adjust;
    default:
      return WalletType.adjust;
  }
}

String walletTypeToString(WalletType t) {
  switch (t) {
    case WalletType.deposit:
      return 'deposit';
    case WalletType.withdraw:
      return 'withdraw';
    case WalletType.refund:
      return 'refund';
    case WalletType.adjust:
      return 'adjust';
  }
}

/// نموذج حركة المحفظة.
class WalletMovementModel {
  final String id;            // UUID أو أي مُعرّف
  final String? dayId;        // قد تكون الحركة عامة بلا ارتباط بيوم
  final DateTime createdAt;
  final WalletType type;
  final double amount;        // قيمة موجبة دائمًا

  /// قيمة موقّعة تُستعمل في الحسابات:
  /// deposit/refund => +amount
  /// withdraw       => -amount
  /// adjust         => قد تعتمد على السياسة؛ هنا نفترض +amount
  double get signedAmount {
    switch (type) {
      case WalletType.deposit:
      case WalletType.refund:
        return amount.abs();
      case WalletType.withdraw:
        return -amount.abs();
      case WalletType.adjust:
        return amount; // اتركها كما هي
    }
  }

  final String? note;

  const WalletMovementModel({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.amount,
    this.dayId,
    this.note,
  });

  WalletMovementModel copyWith({
    String? id,
    String? dayId,
    DateTime? createdAt,
    WalletType? type,
    double? amount,
    String? note,
  }) {
    return WalletMovementModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      dayId: dayId ?? this.dayId,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayId': dayId,
    'createdAt': createdAt.toIso8601String(),
    'type': walletTypeToString(type),
    'amount': amount,
    'note': note,
  };

  factory WalletMovementModel.fromMap(Map<String, dynamic> map) {
    return WalletMovementModel(
      id: map['id'] as String,
      dayId: map['dayId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      type: walletTypeFromString(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());
  static WalletMovementModel fromJson(String source) =>
      WalletMovementModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
