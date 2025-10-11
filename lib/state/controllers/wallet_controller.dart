import 'package:uuid/uuid.dart';
import '../../data/models/wallet_movement_model.dart';
import '../services/outbox_service.dart';
import '../../data/models/outbox_item_model.dart';

class WalletController {
  final _uuid = const Uuid();
  final _outbox = OutboxService();

  final List<WalletMovementModel> _items = [];
  List<WalletMovementModel> get items => List.unmodifiable(_items);

  // رصيد اليوم المحسوب من الحركات فقط (اختياري)
  double totalForDay(String dayId) =>
      _items.where((e) => e.dayId == dayId).fold(0, (s, e) => s + e.amount);

  Future<WalletMovementModel> addMovement({
    required String dayId,
    required WalletType type,
    required double amount,
    String? note,
  }) async {
    final m = WalletMovementModel(
      id: _uuid.v4(),
      dayId: dayId,
      type: type,
      amount: amount,
      note: note ?? '',
    );
    _items.add(m);

    await _outbox.add(OutboxItemModel(
      id: _uuid.v4(),
      kind: 'wallet',
      dayId: dayId,
      payload: {
        'op': type.name,
        ...m.toMap(),
      },
      createdAt: DateTime.now().toUtc(),
    ));

    return m;
  }

  // حفظ حركة "إرجاع مبلغ" (Refund = يدخل للمحفظة بقيمة موجبة)
  Future<WalletMovementModel> addRefund({
    required String dayId,
    required double amount,
    String? note,
  }) async {
    final m = WalletMovementModel(
      id: _uuid.v4(),
      dayId: dayId,
      type: WalletType.refund,
      amount: amount,
      note: note ?? 'Returned cash',
    );
    _items.add(m);

    await _outbox.add(OutboxItemModel(
      id: _uuid.v4(),
      kind: 'wallet',
      dayId: dayId,
      payload: {
        'op': 'refund',
        ...m.toMap(),
      },
      createdAt: DateTime.now().toUtc(),
    ));
    return m;
  }

  // ------- مساعدات واضحة حسب سيناريوك -------

  /// رصيد وارد (Credit) = يدخل للمحفظة بقيمة موجبة
  Future<WalletMovementModel> addCredit({
    required String dayId,
    required double amount,
    String? note,
  }) {
    // نستعمل نفس النوع "refund" كإدخال رصيد عام
    return addMovement(
      dayId: dayId,
      type: WalletType.refund,
      amount: amount.abs(), // موجب
      note: note ?? 'Incoming credit',
    );
  }

  /// خصم بسبب مشتريات (Spend Purchase) = يخرج من المحفظة بقيمة سالبة
  Future<WalletMovementModel> addSpendPurchase({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.purchase,
      amount: -amount.abs(), // سالب
      note: note ?? 'Purchase spend',
    );
  }

  /// خصم بسبب مصروف (Spend Expense) = يخرج من المحفظة بقيمة سالبة
  Future<WalletMovementModel> addSpendExpense({
    required String dayId,
    required double amount,
    String? note,
  }) {
    return addMovement(
      dayId: dayId,
      type: WalletType.expense,
      amount: -amount.abs(), // سالب
      note: note ?? 'Expense spend',
    );
  }
}
