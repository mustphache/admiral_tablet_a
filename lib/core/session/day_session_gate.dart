// lib/core/session/day_session_gate.dart
// Gate جاهز: يمنع شاشة لما اليوم مغلق ويعرض إشعار واضح، أو يمرّرها لما اليوم مفتوح.
// يمكن أيضاً تعيين allowWhenClosed=true لشاشات مسموح بها حتى لو اليوم مغلق (مثل Wallet لو حاب).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/session/day_session_store.dart';

class DaySessionGate extends StatelessWidget {
  final Widget child;
  final bool allowWhenClosed;
  final String? lockedMessage;

  const DaySessionGate({
    super.key,
    required this.child,
    this.allowWhenClosed = false,
    this.lockedMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionStore>.value(
      value: DaySessionStore(),
      child: Consumer<DaySessionStore>(
        builder: (_, store, __) {
          final isOpen = store.state.isOpen;
          if (isOpen || allowWhenClosed) return child;

          return _LockedOverlay(
            message: lockedMessage ??
                'اليوم مغلق حالياً.\nافتح اليوم من شاشة Start Day لتمكين هذه الوظيفة.',
          );
        },
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  final String message;
  const _LockedOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 48),
                const SizedBox(height: 12),
                Text(
                  'مغلق',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('رجوع'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
