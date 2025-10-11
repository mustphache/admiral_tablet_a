import 'package:flutter/material.dart';

// ✅ جلسة اليوم: Gate + الشارة
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

class AddWalletMovementScreen extends StatelessWidget {
  const AddWalletMovementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // المحفظة تبقى متاحة دائمًا
    return DaySessionGate(
      allowWhenClosed: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Wallet Movement'),
          actions: const [DayStatusIndicator()],
        ),
        body: const Center(
          child: Text('Form comes here'),
        ),
      ),
    );
  }
}
