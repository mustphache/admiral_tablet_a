// lib/state/controllers/wallet_controller.dart
import 'package:uuid/uuid.dart';
import '../../data/models/wallet_movement_model.dart';
import '../services/outbox_service.dart';
import '../../data/models/outbox_item_model.dart';
import '../services/kv_store.dart';

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
      ..addAll(list.map((m) => WalletMovementModel.fromMap(m)));
    _loaded = true;
  }

  Future<void> _persist() async {
    await KvStore.setList(
      _kStore,
      _items.map((e) => e.toMap()).toList(),
    );
  }

  double totalForDay(String dayId) =>
      _items.where((e) => e.dayId == dayId).fold(0.0, (s, e) => s + e.signedAmount);

  Future<WalletMovementModel> addMovement({
    required String dayId,
    required WalletType type,
    required double amount,
    String? note,
  }) async {
    await load();
    final now = DateTime.now().toUtc();
    final amt = amount.abs();

    final exists = _items.any((m) =>
    m.dayId == dayId &&
        m.type == type &&
        (m.note ?? '') == (note ?? '') &&
        (m.amount - amt).abs() < 0.000001 &&
        ((m.createdAt.isBefore(now) ? now.difference(m.createdAt) : m.createdAt.difference(now))
            < const Duration(seconds: 2)));

    if (exists) {
      return _items.lastWhere((m) =>
      m.dayId == dayId &&
          m.type == type &&
          (m.note ?? '') == (note ?? '') &&
          (m.amount - amt).abs() < 0.000001);
    }

    final m = WalletMovementModel(
      id: _uuid.v4(),
      dayId: dayId,
      type: type,
      amount: amt,
      note: note,
      createdAt: now,
    );
    _items.add(m);
    await _persist();

    await _outbox.add(
      OutboxItemModel(
        id: _uuid.v4(),
        kind: 'wallet',
        dayId: dayId,
        payload: {'op': type.name, ...m.toMap()},
        createdAt: now,
      ),
    );
    return m;
  }

  Future<WalletMovementModel> addCredit({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.credit,
      amount: amount,
      note: note ?? 'Incoming credit',
    );
  }

  Future<WalletMovementModel> addRefund({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.refund,
      amount: amount,
      note: note ?? 'Refund',
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
      amount: amount,
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
      amount: amount,
      note: note ?? 'Expense spend',
    );
  }
}
