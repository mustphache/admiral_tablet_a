import 'package:admiral_tablet_a/data/models/expense_model.dart';

class ExpenseController {
  ExpenseController._internal();
  static final ExpenseController _instance = ExpenseController._internal();
  factory ExpenseController() => _instance;

  final List<ExpenseModel> _items = [];

  List<ExpenseModel> get items => List.unmodifiable(_items);

  List<ExpenseModel> listByDay(String dayId) =>
      _items.where((e) => e.sessionId == dayId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  Future<void> add(ExpenseModel m) async {
    _items.add(m);
    // TODO: outbox + audit + خصم تلقائي من المحفظة لاحقًا إن أردنا
  }
}
