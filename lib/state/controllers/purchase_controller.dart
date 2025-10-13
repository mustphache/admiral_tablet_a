import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../data/models/purchase_model.dart';
import '../../data/models/wallet_movement.dart';
import 'wallet_controller.dart';

class PurchaseController {
  PurchaseController._internal();
  static final PurchaseController _instance = PurchaseController._internal();
  factory PurchaseController() => _instance;

  final _uuid = const Uuid();
  final List<PurchaseModel> _items = [];
  bool _loaded = false;

  List<PurchaseModel> get items => List.unmodifiable(_items);

  Future<void> load() async {
    if (_loaded) return;
    // TODO: تحميل من التخزين عندك
    _loaded = true;
  }

  List<PurchaseModel> listByDay(String dayId) =>
      _items.where((p) => p.sessionId == dayId).toList();

  List<PurchaseModel> getByDay(String dayId) => listByDay(dayId);

  double totalForDay(String dayId) =>
      listByDay(dayId).fold(0.0, (s, p) => s + (p.total));

  Future<PurchaseModel> add(PurchaseModel p) async {
    await load();
    final created = p.copyWith(id: p.id.isEmpty ? _uuid.v4() : p.id);
    _items.add(created);

    await WalletController().addMovement(
      dayId: created.sessionId,
      type: WalletMovementType.purchaseAdd,
      amount: created.total.abs(),
      note: 'Purchase add (${created.id})',
    );
    return created;
  }

  // التوقيع المطلوب: update(updated: ...)
  Future<PurchaseModel?> update({required PurchaseModel updated}) async {
    await load();
    final idx = _items.indexWhere((x) => x.id == updated.id);
    if (idx == -1) return null;

    final old = _items[idx];
    _items[idx] = updated;

    final delta = (updated.total - old.total);
    if (delta != 0) {
      if (delta > 0) {
        await WalletController().addMovement(
          dayId: updated.sessionId,
          type: WalletMovementType.purchaseEditIncrease,
          amount: delta,
          note: 'Purchase edit delta (${updated.id})',
        );
      } else {
        await WalletController().addMovement(
          dayId: updated.sessionId,
          type: WalletMovementType.purchaseEditDecrease,
          amount: -delta,
          note: 'Purchase edit delta (${updated.id})',
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
      type: WalletMovementType.purchaseDeleteRefund,
      amount: removed.total.abs(),
      note: 'Purchase remove (${removed.id})',
    );
  }
}
