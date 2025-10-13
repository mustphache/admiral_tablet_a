// lib/data/models/wallet_movement.dart

enum WalletMovementType {
  // رأس المال المؤكَّد (دائن نهائيًا)
  capitalConfirmed,

  // المشتريات
  purchaseAdd,            // مدين
  purchaseEditIncrease,   // مدين (Delta>0)
  purchaseEditDecrease,   // دائن (Delta<0)
  purchaseDeleteRefund,   // دائن (إرجاع آخر قيمة)

  // المصروفات
  expenseAdd,             // مدين
  expenseEditIncrease,    // مدين
  expenseEditDecrease,    // دائن
  expenseDeleteRefund,    // دائن

  // عمليات من داخل المحفظة
  walletTopUpFromWorker,  // دائن (إضافة رصيد من جيب العامل)
  walletDecreaseLoss,     // مدين (ضياع/سرقة)
  walletReturnToManager,  // مدين (إعادة رصيد للمانجر)

  // احتياطي
  transferIn,             // دائن
  transferOut,            // مدين
  adjustmentCredit,       // دائن
  adjustmentDebit,        // مدين
}

extension WalletMovementTypeX on WalletMovementType {
  bool get isCredit {
    switch (this) {
      case WalletMovementType.capitalConfirmed:
      case WalletMovementType.purchaseEditDecrease:
      case WalletMovementType.purchaseDeleteRefund:
      case WalletMovementType.expenseEditDecrease:
      case WalletMovementType.expenseDeleteRefund:
      case WalletMovementType.walletTopUpFromWorker:
      case WalletMovementType.transferIn:
      case WalletMovementType.adjustmentCredit:
        return true;
      default:
        return false;
    }
  }

  bool get isDebit => !isCredit;
}

class WalletMovement {
  final String id;
  final String dayId;
  final DateTime createdAt;
  final WalletMovementType type;
  final double amount;         // موجّبة دائمًا
  final String? note;
  final String? externalRefId;
  final bool metadataOnly;

  const WalletMovement({
    required this.id,
    required this.dayId,
    required this.createdAt,
    required this.type,
    required this.amount,
    this.note,
    this.externalRefId,
    this.metadataOnly = false,
  });

  double get signedAmount => type.isCredit ? amount : -amount;

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayId': dayId,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'amount': amount,
    'note': note,
    'externalRefId': externalRefId,
    'metadataOnly': metadataOnly,
  };

  factory WalletMovement.fromMap(Map<String, dynamic> map) {
    return WalletMovement(
      id: map['id'] as String,
      dayId: map['dayId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      type: WalletMovementType.values
          .firstWhere((e) => e.name == map['type']),
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      externalRefId: map['externalRefId'] as String?,
      metadataOnly: (map['metadataOnly'] as bool?) ?? false,
    );
  }
}
// --- Compatibility aliases (keep old names working) ---
typedef WalletType = WalletMovementType;
typedef WalletMovementModel = WalletMovement;