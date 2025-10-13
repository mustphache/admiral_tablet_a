import 'package:uuid/uuid.dart';

import '../../data/models/wallet_movement_model.dart';
import '../services/outbox_service.dart';
import '../../data/models/outbox_item_model.dart';
import 'package:admiral_tablet_a/state/services/kv_store.dart';

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

  /// --------- نقطة مركزية لإضافة أي حركة + حارس منع التكرار ----------
  Future<WalletMovementModel> addMovement({
    required String dayId,
    required WalletType type,
    required double amount,
    String? note,
  }) async {
    await load();

    final now = DateTime.now().toUtc();

    // Idempotency guard: امنع التكرار العرضي لنفس الحركة خلال نافذة قصيرة
    final exists = _items.any((m) =>
    m.dayId == dayId &&
        m.type == type &&
        _isClose(m.createdAt, now) &&
        _eqD(m.amount, amount) &&
        (m.note ?? '') == (note ?? ''));
    if (exists) {
      // رجّع آخر نسخة مطابقة بدل ما نضيف واحدة ثانية
      return _items.lastWhere((m) =>
      m.dayId == dayId &&
          m.type == type &&
          _isClose(m.createdAt, now) &&
          _eqD(m.amount, amount) &&
          (m.note ?? '') == (note ?? ''));
    }

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

    await _outbox.add(
      OutboxItemModel(
        id: _uuid.v4(),
        kind: 'wallet',
        dayId: dayId,
        payload: {'op': type.name, ...m.toMap()},
        createdAt: now,
      ),
    );

    // (Audit) موجود في نسختك – يظل كما هو
    return m;
  }

  // حركات مشتقّة
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
    // رصيد وارد (موجب). أبقينا النوع Refund لأيقونة السهم الأخضر عندك
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

  WalletMovementModel _fromMap(Map m) => WalletMovementModel.fromMap(m);

  // ---------- أدوات مساعدة خاصة بالحارس ----------
  bool _isClose(DateTime a, DateTime b) =>
      (a.isBefore(b) ? b.difference(a) : a.difference(b)) <
          const Duration(seconds: 2);

  bool _eqD(double a, double b) => (a - b).abs() < 0.000001;
}
