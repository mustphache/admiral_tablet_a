import 'package:admiral_tablet_a/data/models/expense_model.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/state/services/kv_store.dart';

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
