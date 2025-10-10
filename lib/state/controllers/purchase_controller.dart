import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import '../../common/helpers/utils.dart';
import '../../state/controllers/wallet_controller.dart';
import '../../data/models/wallet_movement_model.dart';

class PurchaseController {
  static final PurchaseController _i = PurchaseController._();
  factory PurchaseController() => _i;
  PurchaseController._();

  final List<PurchaseModel> _items = [];
  static const _storageKey = 'purchases_list_v1';

  Future<void> restore() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final List data = jsonDecode(raw);
      _items
        ..clear()
        ..addAll(data.map((e) => PurchaseModel.fromMap(Map<String, dynamic>.from(e))));

    } catch (e) {
      debugPrint('⚠️ Purchase restore failed: $e');
    }
  }

  Future<void> save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
      await sp.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('⚠️ Purchase save failed: $e');
    }
  }

  List<PurchaseModel> get items => List.unmodifiable(_items);

  Future<void> add(PurchaseModel m) async {
    m.id ??= DateTime.now().microsecondsSinceEpoch.toString();
    _items.add(m);
    await save();

    // تسجيل العملية في المحفظة 💰
    try {
      final wallet = WalletController();
      await wallet.addMovement(
        dayId: m.sessionId ?? todayISO(),
        type: WalletType.purchase,
        amount: -(m.total ?? m.price ?? 0),
        note: 'Purchase ${m.tagNumber ?? ''}',
      );
    } catch (e) {
      debugPrint('⚠️ Wallet movement not saved for purchase: $e');
    }
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    await save();
  }

  Future<List<PurchaseModel>> getByDay(String sessionId) async {
    return _items.where((e) => e.sessionId == sessionId).toList();
  }

  double totalForDay(String sessionId) {
    return _items
        .where((e) => e.sessionId == sessionId)
        .fold(0.0, (s, e) => s + (e.total ?? e.price ?? 0));
  }

  void clear() => _items.clear();
}
