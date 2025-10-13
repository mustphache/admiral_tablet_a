// lib/state/controllers/purchase_controller.dart
//
// نسخة نظيفة مع إصلاح منطق فرق الرصيد أثناء التعديل
// تربط بالقيم الرسمية في WalletMovementType

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
    // TODO: حمّل من التخزين المحلي إن وجد
    _loaded = true;
  }

  Future<PurchaseModel> add(PurchaseModel p) async {
    await load();
    final now = DateTime.now().toUtc();
    final created = p.copyWith(id: p.id.isEmpty ? _uuid.v4() : p.id, createdAt: now);
    _items.add(created);

    // إضافة شراء = مدين
    await WalletController().addMovement(
      dayId: created.sessionId,
      type: WalletMovementType.purchaseAdd,
      amount: created.total.abs(),
      note: 'Purchase add (${created.id})',
    );

    return created;
  }

  Future<PurchaseModel?> update(PurchaseModel updated) async {
    await load();
    final idx = _items.indexWhere((x) => x.id == updated.id);
    if (idx == -1) return null;

    final old = _items[idx];
    _items[idx] = updated;

    // فرق محفظة: الزيادة تخصم، النقصان يُعاد للمحفظة
    final delta = (updated.total - old.total);
    if (delta != 0) {
      if (delta > 0) {
        // زيادة شراء = حركة مدينة
        await WalletController().addMovement(
          dayId: updated.sessionId,
          type: WalletMovementType.purchaseEditIncrease,
          amount: delta,
          note: 'Purchase edit delta (${updated.id})',
        );
      } else {
        // تخفيض شراء = حركة دائنة
        await WalletController().addMovement(
          dayId: updated.sessionId,
          type: WalletMovementType.purchaseEditDecrease,
          amount: -delta, // موجب
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

    // حذف شراء: نعيد المبلغ للمحفظة كتسوية دائنة
    await WalletController().addMovement(
      dayId: removed.sessionId,
      type: WalletMovementType.adjustmentCredit,
      amount: removed.total.abs(),
      note: 'Purchase remove (${removed.id})',
    );
  }
}
