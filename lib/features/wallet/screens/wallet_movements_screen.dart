import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/ui/app_routes.dart';

// Gate + الشارة
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

class WalletMovementsScreen extends StatelessWidget {
  const WalletMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DaySessionGate(
      allowWhenClosed: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet Movements'),
          actions: const [DayStatusIndicator()],
        ),
        body: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Movement'),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addWalletMovement),
          ),
        ),
      ),
    );
  }
}
