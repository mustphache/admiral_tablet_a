import 'package:flutter/material.dart';
import '../../../ui/app_routes.dart';

// ✅ Gate
import 'package:admiral_tablet_a/core/session/index.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DaySessionGate(
      allowWhenClosed: true, // المحفظة تبقى متاحة حتى لو اليوم مغلق
      child: Scaffold(
        appBar: AppBar(title: const Text('Wallet')),
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
