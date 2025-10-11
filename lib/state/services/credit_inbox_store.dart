// lib/state/services/credit_inbox_store.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// صندوق "رصيد وارد" معلّق إلى أن يؤكّده العامل.
/// نموذج مبسّط: نخزّن مجموعًا واحدًا (double) + قائمة ملاحظات اختيارية.
class CreditInboxStore extends ChangeNotifier {
  static const _kKey = 'credit_inbox_v1';

  double _pendingTotal = 0;
  List<String> _notes = [];

  double get pendingTotal => _pendingTotal;
  List<String> get notes => List.unmodifiable(_notes);

  static final CreditInboxStore _instance = CreditInboxStore._internal();
  CreditInboxStore._internal();
  factory CreditInboxStore() => _instance;

  /// تحميل الحالة من التخزين المحلي
  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kKey);
    if (raw == null) {
      _pendingTotal = 0;
      _notes = [];
      return;
    }
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      _pendingTotal = (map['total'] as num?)?.toDouble() ?? 0.0;
      final ns = map['notes'] as List<dynamic>? ?? const [];
      _notes = ns.map((e) => e.toString()).toList();
    } catch (_) {
      _pendingTotal = 0;
      _notes = [];
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _kKey,
      json.encode({
        'total': _pendingTotal,
        'notes': _notes,
      }),
    );
  }

  /// يضيف رصيدًا واردًا معلّقًا (يُستخدم عند "إرسال رصيد")
  Future<void> addPending(double amount, {String? note}) async {
    _pendingTotal += amount;
    if (note != null && note.trim().isNotEmpty) {
      _notes.add(note.trim());
    }
    await _save();
    notifyListeners();
  }

  /// يمسح الرصيد المعلّق بعد التأكيد
  Future<void> clear() async {
    _pendingTotal = 0;
    _notes = [];
    await _save();
    notifyListeners();
  }
}
