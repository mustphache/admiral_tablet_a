// lib/core/session/day_session_store.dart
import 'package:flutter/foundation.dart';
import 'day_session_model.dart';

/// حافظة حالة (State) للجلسة الحالية.
/// تعتمد ChangeNotifier، لذلك أي مستمعين (Widgets) سيُعاد بناؤهم عند التغيير.
class DaySessionStore extends ChangeNotifier {
  DaySessionModel? _current;

  DaySessionModel? get current => _current;
  bool get hasSession => _current != null;

  /// تعيين جلسة جديدة.
  void setSession(DaySessionModel model) {
    _current = model;
    notifyListeners();
  }

  /// تعديل الجلسة الحالية عبر copyWith.
  void update({
    DateTime? date,
    List<String>? items,
  }) {
    if (_current == null) return;
    _current = _current!.copyWith(date: date, items: items);
    notifyListeners();
  }

  /// مسح الجلسة.
  void clear() {
    _current = null;
    notifyListeners();
  }
}
