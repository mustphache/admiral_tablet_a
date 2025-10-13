import 'package:uuid/uuid.dart';
import '../../data/models/wallet_movement.dart'; // ← كان wallet_movement_model.dart
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

  Future load() async {
    if (_loaded) return;
    final list = await KvStore.getList(_kStore);
    _items
      ..clear()
      ..addAll(list.map((m) => WalletMovementModel.fromMap(m)));
    _loaded = true;
  }

  Future _persist() async {
    await KvStore.setList(_kStore, _items.map((e) => e.toMap()).toList());
  }

  /// مجموع اليوم باستخدام signedAmount الموحّد
  double totalForDay(String dayId) =>
      _items.where((e) => e.dayId == dayId).fold(0.0, (s, e) => s + e.signedAmount);

  // ----------------- نقطة مركزية + حارس منع التكرار -----------------
  Future addMovement({
    required String dayId,
    required WalletType type,
    required double amount,
    String? note,
  }) async {
    await load();

    final now = DateTime.now().toUtc();
    final amt = amount.abs(); // نخزّن بدون إشارة، التوجيه عبر type فقط

    // Idempotency: منع تكرار نفس الحركة خلال نافذة قصيرة
    final exists = _items.any((m) =>
    m.dayId == dayId &&
        m.type == type &&
        (m.note ?? '') == (note ?? '') &&
        _eqD(m.amount, amt) &&
        _isClose(m.createdAt, now));
    if (exists) {
      return _items.lastWhere((m) =>
      m.dayId == dayId &&
          m.type == type &&
          (m.note ?? '') == (note ?? '') &&
          _eqD(m.amount, amt) &&
          _isClose(m.createdAt, now));
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

  // واجهات مختصرة موحّدة (الإشارة تُحدّد عبر النوع)
  Future addCredit({
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

  Future addRefund({
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

  Future addSpendPurchase({
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

  Future addSpendExpense({
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

  // ----------------- أدوات مساعدة للحارس -----------------
  bool _isClose(DateTime a, DateTime b) =>
      (a.isBefore(b) ? b.difference(a) : a.difference(b)) < const Duration(seconds: 2);

  bool _eqD(double a, double b) => (a - b).abs() < 0.000001;
}
