import 'package:flutter/material.dart';
import '../../../ui/app_routes.dart';

// ✅ جلسة اليوم: Gate + الشارة
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

/// من features/wallet/screens إلى ui = ../../../
class WalletMovementsScreen extends StatelessWidget {
  const WalletMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // المحفظة تبقى متاحة دائمًا
    return DaySessionGate(
      allowWhenClosed: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet Movements'),
          actions: const [DayStatusIndicator()],
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.walletMovementAdd),
            child: const Text('Add Movement'),
          ),
        ),
      ),
    );
  }
}
