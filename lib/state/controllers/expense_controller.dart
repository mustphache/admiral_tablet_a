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
    // TODO: تحميل من التخزين عندك
    _loaded = true;
  }

  // مطلوبة في الشاشات/التقارير
  List<ExpenseModel> listByDay(String dayId) =>
      _items.where((e) => e.sessionId == dayId).toList();

  List<ExpenseModel> getByDay(String dayId) => listByDay(dayId);

  double totalForDay(String dayId) =>
      listByDay(dayId).fold(0.0, (s, e) => s + (e.amount));

  Future<ExpenseModel> add(ExpenseModel e) async {
    await load();
    final created = e.copyWith(id: e.id.isEmpty ? _uuid.v4() : e.id);
    _items.add(created);

    await WalletController().addMovement(
      dayId: created.sessionId,
      type: WalletMovementType.expenseAdd,
      amount: created.amount.abs(),
      note: 'Expense add (${created.id})',
    );
    return created;
  }

  // التوقيع المطلوب في الشاشات: update(updated: ...)
  Future<ExpenseModel?> update({required ExpenseModel updated}) async {
    await load();
    final idx = _items.indexWhere((x) => x.id == updated.id);
    if (idx == -1) return null;

    final old = _items[idx];
    _items[idx] = updated;

    final delta = (updated.amount - old.amount);
    if (delta != 0) {
      if (delta > 0) {
        await WalletController().addMovement(
          dayId: updated.sessionId,
          type: WalletMovementType.expenseEditIncrease,
          amount: delta,
          note: 'Expense edit delta (${updated.id})',
        );
      } else {
        await WalletController().addMovement(
          dayId: updated.sessionId,
          type: WalletMovementType.expenseEditDecrease,
          amount: -delta,
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

    await WalletController().addMovement(
      dayId: removed.sessionId,
      type: WalletMovementType.expenseDeleteRefund,
      amount: removed.amount.abs(),
      note: 'Expense remove (${removed.id})',
    );
  }
}
