// lib/data/models/wallet_movement_model.dart
// نموذج حركة المحفظة + أنواعها (موجب/سالب عبر signedAmount)

enum WalletType {
  purchase,          // مدين
  expense,           // مدين
  refund,            // دائن
  credit,            // دائن (top-up عام)
  topUpFromWorker,   // دائن
  loss,              // مدين
  returnToManager,   // مدين
  adjustmentPlus,    // دائن
  adjustmentMinus,   // مدين
}

class WalletMovementModel {
  final String id;
  final String dayId;
  final DateTime createdAt;
  final WalletType type;
  final double amount; // تخزين بدون إشارة دائمًا
  final String? note;

  WalletMovementModel({
    required this.id,
    required this.dayId,
    required this.createdAt,
    required this.type,
    required this.amount,
    this.note,
  });

  double get signedAmount {
    switch (type) {
      case WalletType.purchase:
      case WalletType.expense:
      case WalletType.loss:
      case WalletType.returnToManager:
      case WalletType.adjustmentMinus:
        return -amount;
      case WalletType.refund:
      case WalletType.credit:
      case WalletType.topUpFromWorker:
      case WalletType.adjustmentPlus:
        return amount;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayId': dayId,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'amount': amount,
    'note': note,
  };

  factory WalletMovementModel.fromMap(Map<String, dynamic> m) {
    final tName = (m['type'] as String);
    final t = WalletType.values.firstWhere(
          (e) => e.name == tName,
      orElse: () => WalletType.purchase,
    );
    return WalletMovementModel(
      id: m['id'] as String,
      dayId: m['dayId'] as String,
      createdAt: DateTime.parse(m['createdAt'] as String),
      type: t,
      amount: (m['amount'] as num).toDouble(),
      note: m['note'] as String?,
    );
  }
}
