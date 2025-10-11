// lib/core/session/day_status_indicator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'index.dart';

class DayStatusIndicator extends StatelessWidget {
  const DayStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DaySessionStore>(
      builder: (_, store, __) {
        final isOpen = store.state.isOpen;
        final openedAt = store.state.openedAt;
        final text = isOpen
            ? (openedAt != null
            ? 'مفتوح منذ ${_hhmm(openedAt)}'
            : 'مفتوح')
            : 'مغلق';

        final icon = isOpen ? Icons.lock_open : Icons.lock_outline;
        final color = isOpen
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant;

        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Chip(
            avatar: Icon(icon, size: 18),
            label: Text(text),
            backgroundColor: color,
            side: BorderSide.none,
          ),
        );
      },
    );
  }

  static String _hhmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
