import 'package:flutter/foundation.dart';
import 'day_session_model.dart';

class DaySessionStore extends ChangeNotifier {
  DaySessionState? _state;
  DaySessionState? get state => _state;

  void openSession({required String dayId, DateTime? now}) {
    final t = now ?? DateTime.now();
    _state = DaySessionState(
      dayId: dayId,
      createdAt: t,
      openedAt: t,
    );
    notifyListeners();
  }

  void closeSession({DateTime? now}) {
    if (_state == null || _state!.isClosed) return;
    _state = _state!.copyWith(closedAt: now ?? DateTime.now());
    notifyListeners();
  }

  bool get isOpen => _state?.isOpen ?? false;
  String get dayId => _state?.dayId ?? '';
  DateTime? get createdAt => _state?.createdAt;

  void reset() {
    _state = null;
    notifyListeners();
  }
}
