// lib/data/models/wallet_movement.dart
//
// مرجع موحّد يغطي كل القيم التي تستعملها الكنترولرات والخدمات
// + توافق رجعي عبر typedefs مع الأسماء القديمة.

import 'dart:convert';

enum WalletMovementType {
  // إضافات أساسية
  purchaseAdd,
  expenseAdd,

  // تعديلات على مبالغ موجودة
  purchaseEditIncrease,
  purchaseEditDecrease,
  expenseEditIncrease,
  expenseEditDecrease,

  // حذف/استرجاع
  purchaseDeleteRefund,
  expenseDeleteRefund,
  purchaseDeleteReject, // متروك للتوافق

  // تحويلات داخلية
  walletTopUpFromWorker,
  walletDecreaseLoss,
  walletReturnToManager,

  // تسويات/توثيق
  adjustmentCredit,
  adjustmentDebit,
  capitalConfirmed, // متروك للتوافق
}

/// امتداد لتلبية استدعاءات wallet_service: enum.isCredit
extension WalletMovementTypeX on WalletMovementType {
  bool get isCredit {
    switch (this) {
    // تزيد الرصيد (دائنة)
      case WalletMovementType.purchaseEditDecrease:
      case WalletMovementType.expenseEditDecrease:
      case WalletMovementType.purchaseDeleteRefund:
      case WalletMovementType.expenseDeleteRefund:
      case WalletMovementType.walletTopUpFromWorker:
      case WalletMovementType.walletReturnToManager:
      case WalletMovementType.adjustmentCredit:
      case WalletMovementType.capitalConfirmed:
      case WalletMovementType.purchaseDeleteReject:
        return true;

    // تنقص الرصيد (مدينة)
      case WalletMovementType.purchaseAdd:
      case WalletMovementType.expenseAdd:
      case WalletMovementType.purchaseEditIncrease:
      case WalletMovementType.expenseEditIncrease:
      case WalletMovementType.walletDecreaseLoss:
      case WalletMovementType.adjustmentDebit:
        return false;
    }
  }
}

class WalletMovement {
  final String id;
  final String dayId;
  final DateTime createdAt; // UTC
  final WalletMovementType type;

  /// يُخزَّن دائمًا موجب؛ الإشارة تُستنتج من النوع.
  final double amount;
  final String? note;

  // حقول إضافية لتوافق الخدمات
  final String? externalRefId;
  final bool metadataOnly;
  final bool isCredit; // احتفاظ للتوافق مع تخزين سابق إن كان موجود
  final bool isEmpty;

  const WalletMovement({
    required this.id,
    required this.dayId,
    required this.createdAt,
    required this.type,
    required this.amount,
    this.note,
    this.externalRefId,
    this.metadataOnly = false,
    this.isCredit = false,
    this.isEmpty = false,
  });

  double get signedAmount {
    switch (type) {
    // مدينة (تنقص الرصيد)
      case WalletMovementType.purchaseAdd:
      case WalletMovementType.expenseAdd:
      case WalletMovementType.purchaseEditIncrease:
      case WalletMovementType.expenseEditIncrease:
      case WalletMovementType.walletDecreaseLoss:
      case WalletMovementType.adjustmentDebit:
        return -amount;

    // دائنة (تزيد الرصيد)
      case WalletMovementType.purchaseEditDecrease:
      case WalletMovementType.expenseEditDecrease:
      case WalletMovementType.purchaseDeleteRefund:
      case WalletMovementType.expenseDeleteRefund:
      case WalletMovementType.walletTopUpFromWorker:
      case WalletMovementType.walletReturnToManager:
      case WalletMovementType.adjustmentCredit:
      case WalletMovementType.capitalConfirmed:
      case WalletMovementType.purchaseDeleteReject:
        return amount;
    }
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
    bool? isCredit,
    bool? isEmpty,
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
      isCredit: isCredit ?? this.isCredit,
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayId': dayId,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'amount': amount,
    'note': note,
    'externalRefId': externalRefId,
    'metadataOnly': metadataOnly,
    'isCredit': isCredit,
    'isEmpty': isEmpty,
  };

  factory WalletMovement.fromMap(Map<String, dynamic> m) {
    final tName = (m['type'] as String?) ?? 'adjustmentDebit';
    final t = WalletMovementType.values.firstWhere(
          (e) => e.name == tName,
      orElse: () => WalletMovementType.adjustmentDebit,
    );
    return WalletMovement(
      id: m['id'] as String,
      dayId: m['dayId'] as String,
      createdAt:
      DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
      type: t,
      amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
      note: m['note'] as String?,
      externalRefId: m['externalRefId'] as String?,
      metadataOnly: m['metadataOnly'] == true,
      isCredit: m['isCredit'] == true,
      isEmpty: m['isEmpty'] == true,
    );
  }

  String toJson() => jsonEncode(toMap());
  static WalletMovement fromJson(String s) =>
      WalletMovement.fromMap(jsonDecode(s) as Map<String, dynamic>);
}

// ——— توافق رجعي ———
// أي ملف قديم يذكر WalletType/WalletMovementModel سيشتغل
typedef WalletType = WalletMovementType;
typedef WalletMovementModel = WalletMovement;
