import 'package:admiral_tablet_a/data/models/expense_model.dart';

/// وحدة التحكم في المصاريف (محلية حالياً)
class ExpenseController {
  ExpenseController._internal();
  static final ExpenseController _instance = ExpenseController._internal();
  factory ExpenseController() => _instance;

  final List<ExpenseModel> _items = [];

  /// كل العناصر (للعرض أو التقارير)
  List<ExpenseModel> get items => List.unmodifiable(_items);

  /// إرجاع المصاريف ليوم معين
  List<ExpenseModel> listByDay(String dayId) =>
      _items.where((e) => e.sessionId == dayId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // ================================================================
  // توافق مؤقت مع الشاشات القديمة (سيُحذف لاحقاً)
  // ================================================================

  List<ExpenseModel> getByDay(String dayId) => listByDay(dayId);

  double totalForDay(String dayId) =>
      listByDay(dayId).fold(0, (s, e) => s + e.amount);

  void restore() {}

  // ================================================================
  // إضافة مصروف جديد (يُضاف لاحقاً outbox + audit log)
  // ================================================================
  Future<void> add(ExpenseModel m) async {
    _items.add(m);
    // TODO: لاحقاً نضيف Outbox + Audit + خصم تلقائي من المحفظة
  }
}
