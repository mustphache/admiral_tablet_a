import 'package:admiral_tablet_a/data/models/purchase_model.dart';

class PurchaseController {
  PurchaseController._internal();
  static final PurchaseController _instance = PurchaseController._internal();
  factory PurchaseController() => _instance;

  final List<PurchaseModel> _items = [];

  /// كل العناصر (للإختبارات/العرض)
  List<PurchaseModel> get items => List.unmodifiable(_items);

  /// عناصر يوم معيّن
  List<PurchaseModel> listByDay(String dayId) =>
      _items.where((e) => e.sessionId == dayId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
// مؤقتًا لتوافق الشاشات القديمة
  List<PurchaseModel> getByDay(String dayId) => listByDay(dayId);
  double totalForDay(String dayId) =>
      listByDay(dayId).fold(0, (s, e) => s + e.total);
  void restore() {}

  /// إضافة شراء للذاكرة (وممكن لاحقًا نضيف Outbox/Audit هنا)
  Future<void> add(PurchaseModel m) async {
    _items.add(m);
    // TODO: لاحقًا نضيف outbox + audit + خصم تلقائي من المحفظة عند الاعتماد النهائي
  }
}
