import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/helpers/utils.dart';
import 'package:admiral_tablet_a/data/models/expense_model.dart';
import '../controllers/wallet_controller.dart';
import '../../data/models/wallet_movement_model.dart';

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

class ExpenseController {
  static final ExpenseController _i = ExpenseController._();
  factory ExpenseController() => _i;
  ExpenseController._();

  final List<ExpenseModel> _items = [];

  static const _storageKey = 'expenses_list_v1';

  Future<void> restore() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final List data = jsonDecode(raw);
      _items
        ..clear()
        ..addAll(data.map((e) => ExpenseModel.fromMap(Map<String, dynamic>.from(e))));

    } catch (e) {
      debugPrint('⚠️ Expense restore failed: $e');
    }
  }

  Future<void> save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
      await sp.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('⚠️ Expense save failed: $e');
    }
  }

  List<ExpenseModel> get items => List.unmodifiable(_items);

  Future<void> add(ExpenseModel m) async {
    m.id ??= _newId();
    _items.add(m);
    await save();

    // تسجيل في المحفظة 💰
    try {
      final wallet = WalletController();
      await wallet.addMovement(
        dayId: m.sessionId ?? todayISO(),
        type: WalletType.expense,
        amount: -(m.amount ?? 0),
        note: 'Expense ${m.note ?? ''}',
      );
    } catch (e) {
      debugPrint('⚠️ Wallet movement not saved for expense: $e');
    }
  }

  Future<List<ExpenseModel>> getByDay(String sessionId) async {
    return _items.where((e) => e.sessionId == sessionId).toList();
  }

  double totalForDay(String sessionId) {
    return _items
        .where((e) => e.sessionId == sessionId)
        .fold(0.0, (s, e) => s + (e.amount ?? 0));
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    await save();
  }

  void clear() => _items.clear();
}
