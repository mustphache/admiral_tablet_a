export 'day_status_indicator.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';

class DaySessionGate extends StatelessWidget {
  final Widget child;
  final bool allowWhenClosed; // للعرض فقط
  const DaySessionGate({
    super.key,
    required this.child,
    this.allowWhenClosed = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      builder: (_, __) {
        return Consumer<DaySessionController>(
          builder: (_, ctrl, __) {
            final canShow = allowWhenClosed || ctrl.isOn;
            if (!canShow) {
              return const _BlockedOverlay();
            }
            return child;
          },
        );
      },
    );
  }
}

class _BlockedOverlay extends StatelessWidget {
  const _BlockedOverlay();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 40),
              SizedBox(height: 12),
              Text('وضع القراءة فقط (Session OFF)'),
              SizedBox(height: 8),
              Text('انتقل إلى الشاشة الرئيسية لتفعيل Session للكتابة'),
            ],
          ),
        ),
      ),
    );
  }
}
