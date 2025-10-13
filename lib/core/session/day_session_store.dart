// lib/core/session/day_session_store.dart
import 'package:flutter/foundation.dart';
import 'day_session_model.dart';

class DaySessionStore extends ChangeNotifier {
  DaySessionState? _state;
  DaySessionState? get state => _state;

  void openSession({ required String dayId, DateTime? now }) {
    final dt = now ?? DateTime.now();
    _state = DaySessionState(
      id: dayId,
      market: '',
      openingCash: 0,
      createdAt: dt,
    );
    notifyListeners();
  }

  void closeSession({ DateTime? now }) {
    if (_state == null) return;
    if (_state!.isOpen == false) return;
    _state = _state!.copyWith(closedAt: now ?? DateTime.now());
    notifyListeners();
  }

  bool get isOpen => _state?.isOpen ?? false;
  String get dayId => _state?.id ?? '';
  DateTime? get createdAt => _state?.createdAt;

  void reset() {
    _state = null;
    notifyListeners();
  }
}
