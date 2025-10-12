import 'package:admiral_tablet_a/data/models/expense_model.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/state/services/kv_store.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement_model.dart';

class ExpenseController {
  ExpenseController._internal();
  static final ExpenseController _instance = ExpenseController._internal();
  factory ExpenseController() => _instance;

  static const _kStore = 'expenses_store_v1';

  final List<ExpenseModel> _items = [];
  bool _loaded = false;

  List<ExpenseModel> get items => List.unmodifiable(_items);

  Future<void> load() async {
    if (_loaded) return;
    final list = await KvStore.getList(_kStore);
    _items
      ..clear()
      ..addAll(list.map(_fromMap));
    _loaded = true;
  }

  Future<void> _persist() async {
    await KvStore.setList(_kStore, _items.map(_toMap).toList());
  }

  List<ExpenseModel> listByDay(String dayId) =>
      _items.where((e) => e.sessionId == dayId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // توافق مؤقت
  List<ExpenseModel> getByDay(String d) => listByDay(d);
  double totalForDay(String d) => listByDay(d).fold(0, (s, e) => s + e.amount);
  void restore() {}

  // إضافة + خصم من المحفظة + حفظ
  Future<void> add(ExpenseModel m) async {
    await load();
    _items.add(m);
    await _persist();
    await WalletController().addSpendExpense(
      dayId: m.sessionId,
      amount: m.amount,
      note: 'Expense #${m.id}',
    );
  }

  // تحديث + فرق محفظة + حفظ
  Future<void> update({
    required String id,
    required ExpenseModel updated,
  }) async {
    await load();
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final old = _items[idx];
    _items[idx] = updated;
    await _persist();

    final delta = updated.amount - old.amount;
    if (delta != 0) {
      await WalletController().addMovement(
        dayId: updated.sessionId,
        type: WalletType.expense,
        amount: -delta, // زيادة المصروف = خصم إضافي (سالب)
        note: 'Expense edit delta (${updated.id})',
      );
    }
  }

  // حذف + عكس أثر المحفظة + حفظ
  Future<void> removeById(String id) async {
    await load();
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final m = _items.removeAt(idx);
    await _persist();

    await WalletController().addRefund(
      dayId: m.sessionId,
      amount: m.amount,
      note: 'Expense deleted (${m.id})',
    );
  }

  Map<String, dynamic> _toMap(ExpenseModel m) => {
    'id': m.id,
    'sessionId': m.sessionId,
    'kind': m.kind,
    'amount': m.amount,
    'timestamp': m.timestamp.toIso8601String(),
    'note': m.note,
  };

  ExpenseModel _fromMap(Map<String, dynamic> m) => ExpenseModel(
    id: m['id'] as String,
    sessionId: m['sessionId'] as String,
    kind: (m['kind'] as String?) ?? '',
    amount: (m['amount'] as num).toDouble(),
    timestamp: DateTime.parse(m['timestamp'] as String),
    note: m['note'] as String?,
  );
}
