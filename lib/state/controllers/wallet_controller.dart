import 'package:uuid/uuid.dart';

import '../../data/models/wallet_movement_model.dart';
import '../services/outbox_service.dart';
import '../../data/models/outbox_item_model.dart';

import 'package:admiral_tablet_a/state/services/kv_store.dart';

// (Audit موجود مسبقًا عندك – نتركه كما هو)

class WalletController {
  WalletController._internal();
  static final WalletController _instance = WalletController._internal();
  factory WalletController() => _instance;

  static const _kStore = 'wallet_movements_store_v1';

  final _uuid = const Uuid();
  final _outbox = OutboxService();

  final List<WalletMovementModel> _items = [];
  bool _loaded = false;

  List<WalletMovementModel> get items => List.unmodifiable(_items);

  Future<void> load() async {
    if (_loaded) return;
    final list = await KvStore.getList(_kStore);
    _items
      ..clear()
      ..addAll(list.map(_fromMap));
    _loaded = true;
  }

  Future<void> _persist() async {
    await KvStore.setList(_kStore, _items.map((e) => e.toMap()).toList());
  }

  double totalForDay(String dayId) =>
      _items.where((e) => e.dayId == dayId).fold(0.0, (s, e) => s + e.amount);

  Future<WalletMovementModel> addMovement({
    required String dayId,
    required WalletType type,
    required double amount,
    String? note,
  }) async {
    await load();
    final now = DateTime.now().toUtc();

    final m = WalletMovementModel(
      id: _uuid.v4(),
      dayId: dayId,
      type: type,
      amount: amount,
      note: note,
      createdAt: now,
    );

    _items.add(m);
    await _persist();

    await _outbox.add(OutboxItemModel(
      id: _uuid.v4(),
      kind: 'wallet',
      dayId: dayId,
      payload: {'op': type.name, ...m.toMap()},
      createdAt: now,
    ));

    // Audit موجود مسبقًا في نسختك—نتركه

    return m;
  }

  Future<WalletMovementModel> addRefund({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.refund,
      amount: -amount.abs(),
      note: note ?? 'Returned cash',
    );
  }

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

  WalletMovementModel _fromMap(Map<String, dynamic> m) =>
      WalletMovementModel.fromMap(m);
}
