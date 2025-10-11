import 'package:flutter/material.dart';
import '../../../ui/app_routes.dart';

// Gate + Indicator
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DaySessionGate(
      allowWhenClosed: true, // المحفظة مسموحة حتى لو اليوم مغلق
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          actions: const [DayStatusIndicator()],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Wallet overview placeholder'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.walletMovements),
                child: const Text('Open Movements'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
