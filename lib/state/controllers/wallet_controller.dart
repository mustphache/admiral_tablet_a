// lib/state/controllers/wallet_controller.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/wallet_movement.dart';
import '../services/outbox_service.dart';
import '../../data/models/outbox_item_model.dart';
import '../services/kv_store.dart';

class WalletController extends ChangeNotifier {
  WalletController._internal();
  static final WalletController _instance = WalletController._internal();
  factory WalletController() => _instance;

  static const _kStore = 'wallet_movements_store_v1';
  final _uuid = const Uuid();
  final _outbox = OutboxService();
  final List<WalletMovement> _items = [];
  bool _loaded = false;

  List<WalletMovement> get items => List.unmodifiable(_items);

  Future<void> load() async {
    if (_loaded) return;
    final list = await KvStore.getList(_kStore);
    _items
      ..clear()
      ..addAll(list.map((m) => WalletMovement.fromMap(m)));
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await KvStore.setList(
      _kStore,
      _items.map((e) => e.toMap()).toList(),
    );
  }

  double totalForDay(String dayId) =>
      _items.where((e) => e.dayId == dayId).fold(0.0, (s, e) => s + e.signedAmount);

  Future<WalletMovement> addMovement({
    required String dayId,
    required WalletMovementType type,
    required double amount,
    String? note,
    String? externalRefId,
    bool metadataOnly = false,
  }) async {
    await load();
    final now = DateTime.now().toUtc();
    final m = WalletMovement(
      id: _uuid.v4(),
      dayId: dayId,
      createdAt: now,
      type: type,
      amount: amount.abs(),
      note: note,
      externalRefId: externalRefId,
      metadataOnly: metadataOnly,
      isCredit: type == WalletMovementType.adjustmentCredit ||
          type == WalletMovementType.purchaseEditDecrease ||
          type == WalletMovementType.expenseEditDecrease ||
          type == WalletMovementType.purchaseDeleteRefund ||
          type == WalletMovementType.expenseDeleteRefund ||
          type == WalletMovementType.walletTopUpFromWorker ||
          type == WalletMovementType.walletReturnToManager ||
          type == WalletMovementType.capitalConfirmed,
      isEmpty: amount == 0,
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

    notifyListeners();
    return m;
  }

  // Shortcuts متوافقة مع القيم الجديدة
  Future addSpendPurchase({
    required String dayId,
    required double amount,
    String? note,
  }) =>
      addMovement(
        dayId: dayId,
        type: WalletMovementType.purchaseAdd,
        amount: amount,
        note: note ?? 'Purchase spend',
      );

  Future addSpendExpense({
    required String dayId,
    required double amount,
    String? note,
  }) =>
      addMovement(
        dayId: dayId,
        type: WalletMovementType.expenseAdd,
        amount: amount,
        note: note ?? 'Expense spend',
      );

  Future addCredit({
    required String dayId,
    required double amount,
    String? note,
  }) =>
      addMovement(
        dayId: dayId,
        type: WalletMovementType.walletTopUpFromWorker,
        amount: amount,
        note: note ?? 'Incoming credit',
      );
}
