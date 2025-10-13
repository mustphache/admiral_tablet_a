// lib/core/session/day_session_gate.dart
import 'package:flutter/widgets.dart';
import 'day_session_store.dart';

class DaySessionGate extends InheritedWidget {
  final DaySessionStore store;

  const DaySessionGate({
    super.key,
    required this.store,
    required Widget child,
  }) : super(child: child);

  static DaySessionGate? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DaySessionGate>();
  }

  @override
  bool updateShouldNotify(covariant DaySessionGate oldWidget) {
    return oldWidget.store != store;
  }
}
