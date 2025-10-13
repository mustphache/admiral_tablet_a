// lib/features/wallet/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';


class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletController>();
    final items = wallet.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder(
              future: wallet.load(),
              builder: (_, __) => Text(
                'Balance: ${items.fold<double>(0, (s, m) => s + m.signedAmount).toStringAsFixed(2)}',
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = items[i];
                return ListTile(
                  title: Text(
                    '${m.type.name} • ${m.amount.toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    '${m.dayId} • ${m.createdAt.toIso8601String()}'
                        '${m.note == null ? '' : '\n${m.note}'}',
                  ),
                  trailing: Text(m.signedAmount.toStringAsFixed(2)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
