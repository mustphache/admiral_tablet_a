import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'day_session_model.dart';

class DaySessionStore extends ChangeNotifier {
  static const _kKey = 'day_session_state_v1';

  DaySessionState _state = DaySessionState.closed();
  DaySessionState get state => _state;

  static final DaySessionStore _instance = DaySessionStore._internal();
  DaySessionStore._internal();
  factory DaySessionStore() => _instance;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kKey);
    if (raw == null) {
      _state = DaySessionState.closed();
      return;
    }
    try {
      final Map<String, dynamic> map = json.decode(raw) as Map<String, dynamic>;
      _state = DaySessionState.fromJson(map);
    } catch (_) {
      _state = DaySessionState.closed();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kKey, json.encode(_state.toJson()));
  }

  Future<void> openDay() async {
    _state = DaySessionState.openedNow();
    await _save();
    notifyListeners();
  }

  Future<void> closeDay() async {
    _state = DaySessionState.closed();
    await _save();
    notifyListeners();
  }
}
