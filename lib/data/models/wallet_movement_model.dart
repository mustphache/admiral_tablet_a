// نموذج حركة المحفظة + توحيد الإشارة عبر signedAmount

enum WalletType {
  credit,   // رصيد وارد (زيادة)
  refund,   // استرجاع (زيادة)
  purchase, // شراء (نقصان)
  expense,  // مصروف (نقصان)
}

class WalletMovementModel {
  final String id;
  final String dayId;       // YYYY-MM-DD
  final WalletType type;
  final double amount;      // نخزّن دائمًا القيمة بالمطلق (بدون إشارة)
  final String? note;
  final DateTime createdAt; // UTC

  WalletMovementModel({
    required this.id,
    required this.dayId,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  /// الإشارة الموحّدة للعرض والحساب:
  /// credit/refund => +amount  |  purchase/expense => -amount
  double get signedAmount {
    switch (type) {
      case WalletType.credit:
      case WalletType.refund:
        return amount.abs();
      case WalletType.purchase:
      case WalletType.expense:
        return -amount.abs();
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayId': dayId,
    'type': type.name,
    'amount': amount,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  static WalletMovementModel fromMap(Map<String, dynamic> map) {
    final t = WalletType.values.firstWhere(
          (e) => e.name == map['type'],
      orElse: () => WalletType.credit,
    );
    return WalletMovementModel(
      id: map['id'] as String,
      dayId: map['dayId'] as String,
      type: t,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
