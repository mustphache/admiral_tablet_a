import 'package:uuid/uuid.dart';
import '../../data/models/wallet_movement_model.dart';
import '../services/outbox_service.dart';
import '../../data/models/outbox_item_model.dart';


class WalletController {
  final _uuid = const Uuid();
  final _outbox = OutboxService();

  final List<WalletMovementModel> _items = [];
  List<WalletMovementModel> get items => List.unmodifiable(_items);

  // رصيد اليوم المحسوب من الحركات فقط (اختياري)
  double totalForDay(String dayId) =>
      _items.where((e) => e.dayId == dayId).fold<double>(0, (s, e) => s + e.amount);
  Future<WalletMovementModel> addMovement({
    required String dayId,
    required WalletType type,
    required double amount,
    String? note,
  }) async {
    final m = WalletMovementModel(
      id: _uuid.v4(),
      dayId: dayId,
      type: type,
      amount: amount,
      note: note ?? '',
    );

    _items.add(m);

    await _outbox.add(OutboxItemModel(
      id: _uuid.v4(),
      kind: 'wallet',
      dayId: dayId,
      payload: {
        'op': type.name,
        ...m.toMap(),
      },
      createdAt: DateTime.now().toUtc(),
    ));

    return m;
  }

  // حفظ حركة "إرجاع مبلغ" (Refund = يدخل للمحفظة بقيمة موجبة)
  Future<WalletMovementModel> addRefund({
    required String dayId,
    required double amount,
    String? note,
  }) async {
    final m = WalletMovementModel(
      id: _uuid.v4(),
      dayId: dayId,
      type: WalletType.refund,
      amount: amount,
      note: note ?? 'Returned cash',
    );

    _items.add(m);

    // دفع إلى Outbox
    await _outbox.add(OutboxItemModel(
      id: _uuid.v4(),
      kind: 'wallet',
      dayId: dayId,
      payload: {
        'op': 'refund',
        ...m.toMap(),
      },
      createdAt: DateTime.now().toUtc(),
    ));

    return m;
  }
}
