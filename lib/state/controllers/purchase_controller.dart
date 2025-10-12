import 'package:admiral_tablet_a/data/models/purchase_model.dart';

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

  // ================================================================
  // توافق مؤقت مع الشاشات القديمة (سيُحذف لاحقاً عند الانتقال للنظام الجديد)
  // ================================================================

  /// نفس وظيفة listByDay() للاسم القديم
  List<PurchaseModel> getByDay(String dayId) => listByDay(dayId);

  /// مجموع المشتريات ليوم محدد
  double totalForDay(String dayId) =>
      listByDay(dayId).fold(0, (s, e) => s + e.total);

  /// لا تقوم بشيء حالياً (لتوافق مؤقت فقط)
  void restore() {}

  // ================================================================
  // إضافة عملية شراء جديدة (يُضاف مستقبلاً outbox + audit log)
  // ================================================================
  Future<void> add(PurchaseModel m) async {
    _items.add(m);
    // TODO: لاحقاً نضيف Outbox + Audit + خصم تلقائي من المحفظة
  }
}
