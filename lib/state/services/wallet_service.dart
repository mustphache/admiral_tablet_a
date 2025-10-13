import 'package:uuid/uuid.dart';
import 'package:admiral_tablet_a/common/helpers/amount_helpers.dart';
import 'package:admiral_tablet_a/data/db/wallet_repository.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement.dart';
import 'package:admiral_tablet_a/data/models/wallet_state.dart';
import 'package:admiral_tablet_a/state/services/errors.dart';

/// خدمة المحفظة — القلب المنطقي المعتمد في كل الشاشات
class WalletService {
  final IWalletRepository repo;
  final Uuid _uuid = const Uuid();

  WalletService(this.repo);

  // ======== قراءة الحالة ========

  /// احسب حالة اليوم لحظيًا (Opening + Credits − Debits)
  Future<WalletState> getState({
    required String dayId,
    required double openingBalance,
  }) async {
    final list = await repo.listByDay(dayId);
    double credits = 0;
    double debits = 0;

    for (final m in list) {
      if (m.metadataOnly) continue; // تغييرات وصفية بلا أثر مالي
      if (m.type.isCredit) {
        credits += m.amount;
      } else {
        debits += m.amount;
      }
    }
    return WalletState(
      dayId: dayId,
      openingBalance: round2(openingBalance),
      credits: round2(credits),
      debits: round2(debits),
    );
  }

  Future<double> _currentBalance(String dayId, double openingBalance) async {
    final state = await getState(dayId: dayId, openingBalance: openingBalance);
    return state.currentBalance;
  }

  Future<void> _ensureSufficient({
    required String dayId,
    required double openingBalance,
    required double requiredDebit,
  }) async {
    final current = await _currentBalance(dayId, openingBalance);
    if (requiredDebit > current) {
      throw InsufficientBalanceError(current, requiredDebit);
    }
  }

  // ======== مُنشئ الحركة ========

  WalletMovement _movement({
    required String dayId,
    required WalletMovementType type,
    required double amount,
    String? note,
    String? externalRefId,
    bool metadataOnly = false,
    DateTime? createdAt,
  }) {
    return WalletMovement(
      id: _uuid.v4(),
      dayId: dayId,
      createdAt: createdAt ?? DateTime.now(),
      type: type,
      amount: requirePositiveAmount(amount),
      note: note,
      externalRefId: externalRefId,
      metadataOnly: metadataOnly,
    );
  }

  // ======== رأس المال (Confirmed Only / Immutable) ========

  Future<void> confirmCapital({
    required String dayId,
    required double amount,
    String? note,
    String? capitalRefId,
  }) async {
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.capitalConfirmed,
      amount: amount,
      note: note ?? 'Capital confirmed',
      externalRefId: capitalRefId,
    );
    await repo.add(m);
  }

  Future<void> guardCapitalIsImmutable() async {
    throw ImmutableCapitalError();
  }

  // ======== المشتريات ========

  /// Add Purchase (مدين)
  Future<void> addPurchase({
    required String dayId,
    required double openingBalance,
    required double amount,
    required String purchaseId,
    String? note,
  }) async {
    await _ensureSufficient(dayId: dayId, openingBalance: openingBalance, requiredDebit: amount);
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.purchaseAdd,
      amount: amount,
      note: note ?? 'Purchase',
      externalRefId: purchaseId,
    );
    await repo.add(m);
  }

  /// Edit Purchase: Old→New
  /// Delta = New - Old
  /// - Delta>0 ⇒ مدين (increase) — يحتاج رصيد كافٍ
  /// - Delta<0 ⇒ دائن (decrease)
  /// - Delta=0 ⇒ لا تغيير مالي (نمنع الحفظ من UI)
  Future<void> editPurchase({
    required String dayId,
    required double openingBalance,
    required double oldAmount,
    required double newAmount,
    required String purchaseId,
    String? note,
  }) async {
    final oldA = requirePositiveAmount(oldAmount);
    final newA = requirePositiveAmount(newAmount);
    final delta = double.parse((newA - oldA).toStringAsFixed(2));

    if (delta == 0) {
      throw NoFinancialChangeError();
    }

    if (delta > 0) {
      await _ensureSufficient(dayId: dayId, openingBalance: openingBalance, requiredDebit: delta);
      final m = _movement(
        dayId: dayId,
        type: WalletMovementType.purchaseEditIncrease,
        amount: delta,
        note: note ?? 'Purchase edit (+$delta)',
        externalRefId: purchaseId,
      );
      await repo.add(m);
    } else {
      final credit = delta.abs();
      final m = _movement(
        dayId: dayId,
        type: WalletMovementType.purchaseEditDecrease,
        amount: credit,
        note: note ?? 'Purchase edit (−$credit)',
        externalRefId: purchaseId,
      );
      await repo.add(m);
    }
  }

  /// Delete Purchase → إرجاع آخر قيمة
  Future<void> deletePurchase({
    required String dayId,
    required double lastAmount,
    required String purchaseId,
    String? note,
  }) async {
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.purchaseDeleteRefund,
      amount: lastAmount,
      note: note ?? 'Purchase delete refund',
      externalRefId: purchaseId,
    );
    await repo.add(m);
  }

  // ======== المصروفات ========

  Future<void> addExpense({
    required String dayId,
    required double openingBalance,
    required double amount,
    required String expenseId,
    String? note,
  }) async {
    await _ensureSufficient(dayId: dayId, openingBalance: openingBalance, requiredDebit: amount);
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.expenseAdd,
      amount: amount,
      note: note ?? 'Expense',
      externalRefId: expenseId,
    );
    await repo.add(m);
  }

  Future<void> editExpense({
    required String dayId,
    required double openingBalance,
    required double oldAmount,
    required double newAmount,
    required String expenseId,
    String? note,
  }) async {
    final oldA = requirePositiveAmount(oldAmount);
    final newA = requirePositiveAmount(newAmount);
    final delta = double.parse((newA - oldA).toStringAsFixed(2));

    if (delta == 0) {
      throw NoFinancialChangeError();
    }

    if (delta > 0) {
      await _ensureSufficient(dayId: dayId, openingBalance: openingBalance, requiredDebit: delta);
      final m = _movement(
        dayId: dayId,
        type: WalletMovementType.expenseEditIncrease,
        amount: delta,
        note: note ?? 'Expense edit (+$delta)',
        externalRefId: expenseId,
      );
      await repo.add(m);
    } else {
      final credit = delta.abs();
      final m = _movement(
        dayId: dayId,
        type: WalletMovementType.expenseEditDecrease,
        amount: credit,
        note: note ?? 'Expense edit (−$credit)',
        externalRefId: expenseId,
      );
      await repo.add(m);
    }
  }

  Future<void> deleteExpense({
    required String dayId,
    required double lastAmount,
    required String expenseId,
    String? note,
  }) async {
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.expenseDeleteRefund,
      amount: lastAmount,
      note: note ?? 'Expense delete refund',
      externalRefId: expenseId,
    );
    await repo.add(m);
  }

  // ======== حركات داخل المحفظة ========

  /// إضافة رصيد (من جيب العامل) — دائن
  Future<void> walletTopUpFromWorker({
    required String dayId,
    required double amount,
    String? note,
  }) async {
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.walletTopUpFromWorker,
      amount: amount,
      note: note ?? 'Top-up (worker)',
    );
    await repo.add(m);
  }

  /// إنقاص رصيد (ضياع/سرقة) — مدين مع فحص الرصيد
  Future<void> walletDecreaseLoss({
    required String dayId,
    required double openingBalance,
    required double amount,
    String? note,
  }) async {
    await _ensureSufficient(dayId: dayId, openingBalance: openingBalance, requiredDebit: amount);
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.walletDecreaseLoss,
      amount: amount,
      note: note ?? 'Wallet decrease (loss)',
    );
    await repo.add(m);
  }

  /// إعادة رصيد للمانجر — مدين مع فحص الرصيد
  Future<void> walletReturnToManager({
    required String dayId,
    required double openingBalance,
    required double amount,
    String? note,
  }) async {
    await _ensureSufficient(dayId: dayId, openingBalance: openingBalance, requiredDebit: amount);
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.walletReturnToManager,
      amount: amount,
      note: note ?? 'Return to manager',
    );
    await repo.add(m);
  }

  // ======== تسويات اختيارية ========

  Future<void> adjustmentCredit({
    required String dayId,
    required double amount,
    String? note,
  }) async {
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.adjustmentCredit,
      amount: amount,
      note: note ?? 'Adjustment (+)',
    );
    await repo.add(m);
  }

  Future<void> adjustmentDebit({
    required String dayId,
    required double openingBalance,
    required double amount,
    String? note,
  }) async {
    await _ensureSufficient(dayId: dayId, openingBalance: openingBalance, requiredDebit: amount);
    final m = _movement(
      dayId: dayId,
      type: WalletMovementType.adjustmentDebit,
      amount: amount,
      note: note ?? 'Adjustment (−)',
    );
    await repo.add(m);
  }

  // ======== أداة سريعة ========

  Future<double> current({
    required String dayId,
    required double openingBalance,
  }) => _currentBalance(dayId, openingBalance);
}
