// lib/data/models/wallet_movement.dart
//
// نسخة موحدة تشمل كل أنواع الحركات القديمة والجديدة
// وتغطي القيم المفقودة مثل expenseDeleteRefund, walletDecreaseLoss, ... إلخ
// حتى لا يظهر أي خطأ "no constant named ..."

import 'dart:convert';

enum WalletMovementType {
  // الحركات الأساسية
  purchaseAdd,                // إضافة شراء
  expenseAdd,                 // إضافة مصروف

  // التعديلات على مبالغ موجودة
  purchaseEditIncrease,
  purchaseEditDecrease,
  expenseEditIncrease,
  expenseEditDecrease,

  // حذف / استرجاع
  purchaseDeleteRefund,
  expenseDeleteRefund,

  // تحويلات داخلية
  walletTopUpFromWorker,
  walletDecreaseLoss,
  walletReturnToManager,

  // تسويات عامة
  adjustmentCredit,
  adjustmentDebit,

  // أنواع قديمة لتوافق الريبو
  capitalConfirmed,
  purchaseDeleteReject,
}

class WalletMovement {
  final String id;
  final String dayId;
  final DateTime createdAt;
  final WalletMovementType type;
  final double amount;
  final String? note;

  /// الحقول المضافة لتغطية الأخطاء في wallet_service.dart
  final String? externalRefId;
  final bool metadataOnly;
  final bool isCredit;
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
    // حركات مدينة (تنقص الرصيد)
      case WalletMovementType.purchaseAdd:
      case WalletMovementType.expenseAdd:
      case WalletMovementType.purchaseEditIncrease:
      case WalletMovementType.expenseEditIncrease:
      case WalletMovementType.walletDecreaseLoss:
      case WalletMovementType.adjustmentDebit:
        return -amount;

    // حركات دائنة (تزيد الرصيد)
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
      createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
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

// توافق رجعي مع الأسماء القديمة
typedef WalletType = WalletMovementType;
typedef WalletMovementModel = WalletMovement;
