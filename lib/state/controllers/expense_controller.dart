import 'package:admiral_tablet_a/data/models/expense_model.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';

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

  // ----------------- توافق مؤقت مع الشاشات القديمة -----------------
  List<ExpenseModel> getByDay(String dayId) => listByDay(dayId);
  double totalForDay(String dayId) =>
      listByDay(dayId).fold(0, (s, e) => s + e.amount);
  void restore() {}
  // ------------------------------------------------------------------

  /// إضافة مصروف جديد + خصم تلقائي من المحفظة
  ///
  /// المبلغ المخصوم = `amount` للمصروف.
  /// يتم التسجيل تحت `dayId = m.sessionId` (وهو dayIdToday حالياً).
  Future<void> add(ExpenseModel m) async {
    // 1) خزّن العملية في الذاكرة
    _items.add(m);

    // 2) خصم تلقائي من المحفظة
    try {
      await WalletController().addSpendExpense(
        dayId: m.sessionId,
        amount: m.amount,
        note: 'Expense #${m.id}',
      );
    } catch (_) {
      // نفس الملاحظة كما في المشتريات.
    }
  }
}
