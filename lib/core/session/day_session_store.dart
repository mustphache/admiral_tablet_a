import 'package:flutter/foundation.dart';
import 'day_session_model.dart';

/// Store بسيط لحالة الجلسة (بدون اعتماد على مكتبات خارجية)
class DaySessionStore extends ChangeNotifier {
  DaySessionState? _state;

  DaySessionState? get state => _state;

  /// فتح جلسة جديدة لليوم
  void openSession({
    required String dayId,
    DateTime? now,
  }) {
    final dt = now ?? DateTime.now();
    _state = DaySessionState(
      dayId: dayId,
      createdAt: dt,
      openedAt: dt,
    );
    notifyListeners();
  }

  /// إغلاق الجلسة الحالية
  void closeSession({DateTime? now}) {
    if (_state == null) return;
    if (_state!.isClosed) return;
    _state = _state!.copyWith(closedAt: now ?? DateTime.now());
    notifyListeners();
  }

  /// هل الجلسة مفتوحة الآن؟
  bool get isOpen => _state?.isOpen ?? false;

  /// إرجاع dayId بشكل آمن (أو سلسلة فارغة)
  String get dayId => _state?.dayId ?? '';

  /// createdAt بشكل آمن
  DateTime? get createdAt => _state?.createdAt;

  /// تفريغ الحالة (استعمال إداري)
  void reset() {
    _state = null;
    notifyListeners();
  }
}
