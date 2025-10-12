import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';

/// وحدة التحكم في المشتريات (محلية حالياً، بدون قاعدة بيانات)
class PurchaseController {
  PurchaseController._internal();
  static final PurchaseController _instance = PurchaseController._internal();
  factory PurchaseController() => _instance;

  final List<PurchaseModel> _items = [];

  /// كل العناصر (للعرض أو التقارير)
  List<PurchaseModel> get items => List.unmodifiable(_items);

  /// إرجاع المشتريات ليوم معين
  List<PurchaseModel> listByDay(String dayId) =>
      _items.where((e) => e.sessionId == dayId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // ----------------- توافق مؤقت مع الشاشات القديمة -----------------
  List<PurchaseModel> getByDay(String dayId) => listByDay(dayId);
  double totalForDay(String dayId) =>
      listByDay(dayId).fold(0, (s, e) => s + e.total);
  void restore() {}
  // ------------------------------------------------------------------

  /// إضافة عملية شراء جديدة + خصم تلقائي من المحفظة
  ///
  /// المبلغ المخصوم = `total` للشراء.
  /// يتم التسجيل تحت `dayId = m.sessionId` (وهو dayIdToday حالياً).
  Future<void> add(PurchaseModel m) async {
    // 1) خزّن العملية في الذاكرة
    _items.add(m);

    // 2) خصم تلقائي من المحفظة
    try {
      await WalletController().addSpendPurchase(
        dayId: m.sessionId,
        amount: m.total,
        note: 'Purchase #${m.id}',
      );
    } catch (_) {
      // في الوضع الحالي (محلي)، نكتفي بتجاهل الخطأ حتى لا نفقد الشراء نفسه.
      // لاحقاً ممكن نضيف reconcile/outbox لضمان التطابق.
    }
  }
}
