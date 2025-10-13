// lib/state/controllers/expense_controller.dart
//
// نسخة نظيفة مع إصلاح منطق فرق الرصيد أثناء التعديل
// تربط بالقيم الرسمية في WalletMovementType

import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../data/models/expense_model.dart';
import '../../data/models/wallet_movement.dart';
import 'wallet_controller.dart';

class ExpenseController {
  ExpenseController._internal();
  static final ExpenseController _instance = ExpenseController._internal();
  factory ExpenseController() => _instance;

  final _uuid = const Uuid();
  final List<ExpenseModel> _items = [];
  bool _loaded = false;

  List<ExpenseModel> get items => List.unmodifiable(_items);

  Future<void> load() async {
    if (_loaded) return;
    // TODO: حمّل من التخزين المحلي إن وجد
    _loaded = true;
  }

  Future<ExpenseModel> add(ExpenseModel e) async {
    await load();
    final now = DateTime.now().toUtc();
    final created = e.copyWith(id: e.id.isEmpty ? _uuid.v4() : e.id, createdAt: now);
    _items.add(created);

    // حركة محفظة: إضافة مصروف = مدين
    await WalletController().addMovement(
      dayId: created.sessionId,
      type: WalletMovementType.expenseAdd,
      amount: created.amount.abs(),
      note: 'Expense add (${created.id})',
    );

    return created;
  }

  Future<ExpenseModel?> update(ExpenseModel updated) async {
    await load();
    final idx = _items.indexWhere((x) => x.id == updated.id);
    if (idx == -1) return null;

    final old = _items[idx];
    _items[idx] = updated;

    // فرق محفظة: الزيادة تخصم، النقصان يُعاد للمحفظة
    final delta = (updated.amount - old.amount);
    if (delta != 0) {
      if (delta > 0) {
        // زيادة مصروف = حركة مدينة
        await WalletController().addMovement(
          dayId: updated.sessionId,
          type: WalletMovementType.expenseEditIncrease,
          amount: delta,
          note: 'Expense edit delta (${updated.id})',
        );
      } else {
        // تخفيض مصروف = حركة دائنة
        await WalletController().addMovement(
          dayId: updated.sessionId,
          type: WalletMovementType.expenseEditDecrease,
          amount: -delta, // موجب
          note: 'Expense edit delta (${updated.id})',
        );
      }
    }

    return updated;
  }

  Future<void> removeById(String id) async {
    await load();
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final removed = _items.removeAt(idx);

    // حذف مصروف: نعيد المبلغ للمحفظة كتسوية دائنة
    await WalletController().addMovement(
      dayId: removed.sessionId,
      type: WalletMovementType.adjustmentCredit,
      amount: removed.amount.abs(),
      note: 'Expense remove (${removed.id})',
    );
  }
}
