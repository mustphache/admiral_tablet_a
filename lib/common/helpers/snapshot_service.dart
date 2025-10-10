import 'dart:convert';
import '../../state/controllers/day_session_controller.dart';
import '../../state/controllers/purchase_controller.dart';
import '../../state/controllers/expense_controller.dart';



class SnapshotService {
  Map<String, dynamic> _pickPurchase(dynamic x) {
    try {
      final m = <String, dynamic>{};
      m['id']        = (x.id ?? '').toString();
      m['sessionId'] = (x.sessionId ?? '').toString();
      m['tag']       = (x.tagNumber ?? x.tag ?? '').toString();
      final price    = (x.price ?? 0);
      final total    = (x.total ?? price ?? 0);
      m['price']     = (price is num) ? price.toDouble() : 0.0;
      m['total']     = (total is num) ? total.toDouble() : 0.0;
      m['note']      = (x.note ?? x.notes ?? '').toString();
      return m;
    } catch (_) {
      return {'raw': x.toString()};
    }
  }

  Map<String, dynamic> _pickExpense(dynamic x) {
    try {
      final m = <String, dynamic>{};
      m['id']        = (x.id ?? '').toString();
      m['sessionId'] = (x.sessionId ?? '').toString();
      final amount   = (x.amount ?? 0);
      m['amount']    = (amount is num) ? amount.toDouble() : 0.0;
      m['category']  = (x.category ?? '').toString();
      m['note']      = (x.note ?? x.notes ?? '').toString();
      return m;
    } catch (_) {
      return {'raw': x.toString()};
    }
  }

  Future<String> buildDayJson({
    required DaySessionController day,
    required PurchaseController purchases,
    required ExpenseController expenses,
  }) async {
    final id = day.current?.id ?? '';
    final p  = await purchases.getByDay(id);
    final e  = await expenses.getByDay(id);

    final data = {
      'dayId'       : id,
      'market'      : day.current?.market,
      'openingCash' : day.current?.openingCash ?? 0,
      'purchases'   : p.map(_pickPurchase).toList(),
      'expenses'    : e.map(_pickExpense).toList(),
      'generatedAt' : DateTime.now().toIso8601String(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
