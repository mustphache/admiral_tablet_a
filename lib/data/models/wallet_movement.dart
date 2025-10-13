import 'package:equatable/equatable.dart';

/// أنواع الحركات (مضبوطة بما اتفقنا عليه)
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

  // احتياطي للمستقبل
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

  String get label {
    switch (this) {
      case WalletMovementType.capitalConfirmed: return 'Capital Confirmed';
      case WalletMovementType.purchaseAdd: return 'Purchase';
      case WalletMovementType.purchaseEditIncrease: return 'Purchase Edit (+)';
      case WalletMovementType.purchaseEditDecrease: return 'Purchase Edit (−)';
      case WalletMovementType.purchaseDeleteRefund: return 'Purchase Delete Refund';
      case WalletMovementType.expenseAdd: return 'Expense';
      case WalletMovementType.expenseEditIncrease: return 'Expense Edit (+)';
      case WalletMovementType.expenseEditDecrease: return 'Expense Edit (−)';
      case WalletMovementType.expenseDeleteRefund: return 'Expense Delete Refund';
      case WalletMovementType.walletTopUpFromWorker: return 'Wallet Top-up (Worker)';
      case WalletMovementType.walletDecreaseLoss: return 'Wallet Decrease (Loss)';
      case WalletMovementType.walletReturnToManager: return 'Return to Manager';
      case WalletMovementType.transferIn: return 'Transfer In';
      case WalletMovementType.transferOut: return 'Transfer Out';
      case WalletMovementType.adjustmentCredit: return 'Adjustment (+)';
      case WalletMovementType.adjustmentDebit: return 'Adjustment (−)';
    }
  }
}

class WalletMovement extends Equatable {
  final String id;                 // uuid
  final String dayId;              // مرجع يوم العمل
  final DateTime createdAt;        // Local time
  final WalletMovementType type;
  final double amount;             // تُخزَّن موجّبة دائمًا
  final String? note;

  /// مرجع خارجي اختياري (purchaseId/expenseId/transferRefId)
  final String? externalRefId;

  /// تعديل وصفي فقط؟ (لا أثر مالي) — يُفيد الـAudit
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

  /// المبلغ الموقّع يُشتق من النوع فقط
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
      type: WalletMovementType.values.firstWhere((e) => e.name == map['type']),
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      externalRefId: map['externalRefId'] as String?,
      metadataOnly: (map['metadataOnly'] as bool?) ?? false,
    );
  }

  WalletMovement copyWith({
    String? id,
    String? dayId,
    DateTime? createdAt,
    WalletMovementType? type,
    double? amount,
    String? note,
    String? externalRefId,
    bool? metadataOnly,
  }) {
    return WalletMovement(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      externalRefId: externalRefId ?? this.externalRefId,
      metadataOnly: metadataOnly ?? this.metadataOnly,
    );
  }

  @override
  List<Object?> get props => [id, dayId, createdAt, type, amount, note, externalRefId, metadataOnly];
}
