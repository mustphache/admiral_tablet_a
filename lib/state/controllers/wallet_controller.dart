// lib/state/controllers/wallet_controller.dart
import 'package:uuid/uuid.dart';

import '../../data/models/wallet_movement_model.dart';
import '../services/outbox_service.dart';
import '../../data/models/outbox_item_model.dart';

// ✅ التدقيق
import 'package:admiral_tablet_a/state/services/audit_log_service.dart';
import 'package:admiral_tablet_a/data/models/audit_event_model.dart';

class WalletController {
  final _uuid = const Uuid();
  final _outbox = OutboxService();

  final List<WalletMovementModel> _items = [];
  List<WalletMovementModel> get items => List.unmodifiable(_items);

  double totalForDay(String dayId) =>
      _items.where((e) => e.dayId == dayId).fold(0.0, (s, e) => s + e.amount);

  Future<WalletMovementModel> addMovement({
    required String dayId,
    required WalletType type,
    required double amount,
    String? note,
  }) async {
    final now = DateTime.now().toUtc();

    final m = WalletMovementModel(
      id: _uuid.v4(),
      dayId: dayId,
      type: type,
      amount: amount,
      note: note,
      createdAt: now, // نحفظ ms
    );

    _items.add(m);

    // Outbox (للمزامنة)
    await _outbox.add(OutboxItemModel(
      id: _uuid.v4(),
      kind: 'wallet',
      dayId: dayId,
      payload: {
        'op': type.name,
        ...m.toMap(),
      },
      createdAt: now,
    ));

    // ✅ Audit (Append-only) — “create” لكل حركة جديدة
    await AuditLogService().log(
      entityKind: AuditEntityKind.walletMovement,
      entityId: m.id,
      action: AuditAction.create,
      before: null,
      after: m.toMap(),
      // actor: لاحقًا نقدر نمرّر اسم المستخدم/الجهاز
    );

    return m;
  }

  // دخل للمحفظة (موجب)
  Future<WalletMovementModel> addRefund({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.refund,
      amount: amount.abs(),
      note: note ?? 'Returned cash',
    );
  }

  // رصيد وارد (موجب)
  Future<WalletMovementModel> addCredit({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.refund,
      amount: amount.abs(),
      note: note ?? 'Incoming credit',
    );
  }

  // خصم بسبب مشتريات (سالب)
  Future<WalletMovementModel> addSpendPurchase({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.purchase,
      amount: -amount.abs(),
      note: note ?? 'Purchase spend',
    );
  }

  // خصم بسبب مصروف (سالب)
  Future<WalletMovementModel> addSpendExpense({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.expense,
      amount: -amount.abs(),
      note: note ?? 'Expense spend',
    );
  }
}
