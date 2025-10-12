import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/state/services/kv_store.dart';

class PurchaseController {
  PurchaseController._internal();
  static final PurchaseController _instance = PurchaseController._internal();
  factory PurchaseController() => _instance;

  static const _kStore = 'purchases_store_v1';

  final List<PurchaseModel> _items = [];
  bool _loaded = false;

  List<PurchaseModel> get items => List.unmodifiable(_items);

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

  List<PurchaseModel> listByDay(String dayId) =>
      _items.where((e) => e.sessionId == dayId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // توافق مؤقت
  List<PurchaseModel> getByDay(String d) => listByDay(d);
  double totalForDay(String d) => listByDay(d).fold(0, (s, e) => s + e.total);
  void restore() {} // لم تعد مطلوبة

  // إضافة + خصم من المحفظة + حفظ
  Future<void> add(PurchaseModel m) async {
    await load();
    _items.add(m);
    await _persist();
    await WalletController().addSpendPurchase(
      dayId: m.sessionId,
      amount: m.total,
      note: 'Purchase #${m.id}',
    );
  }

  // تحويلات خفيفة (بدون لمس الموديل الأصلي)
  Map<String, dynamic> _toMap(PurchaseModel m) => {
    'id': m.id,
    'sessionId': m.sessionId,
    'supplier': m.supplier,
    'tagNumber': m.tagNumber,
    'price': m.price,
    'count': m.count,
    'total': m.total,
    'timestamp': m.timestamp.toIso8601String(),
    'note': m.note,
  };

  PurchaseModel _fromMap(Map<String, dynamic> m) => PurchaseModel(
    id: m['id'] as String,
    sessionId: m['sessionId'] as String,
    supplier: (m['supplier'] as String?) ?? '',
    tagNumber: (m['tagNumber'] as String?) ?? '',
    price: (m['price'] as num).toDouble(),
    count: (m['count'] as num).toInt(),
    total: (m['total'] as num).toDouble(),
    timestamp: DateTime.parse(m['timestamp'] as String),
    note: m['note'] as String?,
  );
}
