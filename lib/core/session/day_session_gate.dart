// lib/core/session/day_session_gate.dart
import 'package:flutter/widgets.dart';
import 'day_session_store.dart';

/// بوابة مشاركة DaySessionStore في الشجرة.
/// مبنيّة على InheritedNotifier حتى تُحدَّث الواجهة تلقائياً عند notifyListeners().
class DaySessionGate extends InheritedNotifier<DaySessionStore> {
  const DaySessionGate({
    super.key,
    required DaySessionStore store,
    required Widget child,
  }) : super(notifier: store, child: child);

  /// الحصول على الـStore من الـcontext.
  static DaySessionStore of(BuildContext context) {
    final gate =
    context.dependOnInheritedWidgetOfExactType<DaySessionGate>();
    assert(gate != null, 'DaySessionGate not found in context');
    return gate!.notifier!;
  }
}
