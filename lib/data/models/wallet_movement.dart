// lib/data/models/wallet_movement.dart
//
// المرجع الرسمي لحركات المحفظة + منطق الإشارة + توافق رجعي مع الأسماء القديمة
// (WalletMovementModel / WalletType) حتى ما نكسروش ملفات قديمة.

import 'dart:convert';

/// أنواع الحركات الرسمية المستعملة عبر المشروع
enum WalletMovementType {
  // إضافات أساسية
  purchaseAdd,            // إضافة شراء (مدين)
  expenseAdd,             // إضافة مصروف (مدين)

  // تعديلات على مبالغ موجودة
  purchaseEditIncrease,   // زيادة مبلغ شراء (مدين)
  purchaseEditDecrease,   // تخفيض مبلغ شراء (دائن)
  expenseEditIncrease,    // زيادة مبلغ مصروف (مدين)
  expenseEditDecrease,    // تخفيض مبلغ مصروف (دائن)

  // تعبئة/تحويلات
  walletTopUpFromWorker,  // تعبئة من العامل (دائن)

  // تسويات عامة
  adjustmentCredit,       // تسوية دائنة عامة (دائن)
  adjustmentDebit,        // تسوية مدينة عامة (مدين)
}

class WalletMovement {
  final String id;
  final String dayId;            // اليوم/الجلسة المرتبطة
  final DateTime createdAt;      // UTC
  final WalletMovementType type;
  /// المبلغ يُخزَّن دائماً موجب (الإشارة تُستنتج من النوع)
  final double amount;
  final String? note;

  const WalletMovement({
    required this.id,
    required this.dayId,
    required this.createdAt,
    required this.type,
    required this.amount,
    this.note,
  });

  /// يعيد المبلغ بإشارته حسب النوع
  double get signedAmount {
    switch (type) {
    // مدين (ينقص الرصيد)
      case WalletMovementType.purchaseAdd:
      case WalletMovementType.expenseAdd:
      case WalletMovementType.purchaseEditIncrease:
      case WalletMovementType.expenseEditIncrease:
      case WalletMovementType.adjustmentDebit:
        return -amount;

    // دائن (يزيد الرصيد)
      case WalletMovementType.purchaseEditDecrease:
      case WalletMovementType.expenseEditDecrease:
      case WalletMovementType.walletTopUpFromWorker:
      case WalletMovementType.adjustmentCredit:
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
  }) {
    return WalletMovement(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayId': dayId,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'amount': amount,
    'note': note,
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
      createdAt: DateTime.parse(m['createdAt'] as String),
      type: t,
      amount: (m['amount'] as num).toDouble(),
      note: m['note'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());
  static WalletMovement fromJson(String s) =>
      WalletMovement.fromMap(jsonDecode(s) as Map<String, dynamic>);
}

// --- توافق رجعي مع أسماء قديمة حتى ما نعدلوش عشرات الملفات ---
// (لو فيه ملفات تذكر WalletType أو WalletMovementModel ستظل تشتغل)
typedef WalletType = WalletMovementType;
typedef WalletMovementModel = WalletMovement;
