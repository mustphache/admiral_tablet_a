// lib/features/wallet/screens/wallet_movements_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/controllers/wallet_controller.dart';
import '../../../data/models/wallet_movement.dart';

class WalletMovementsScreen extends StatefulWidget {
  const WalletMovementsScreen({super.key});

  @override
  State<WalletMovementsScreen> createState() => _WalletMovementsScreenState();
}

class _WalletMovementsScreenState extends State<WalletMovementsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletController>().load();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletController>();
    final items = wallet.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Movements')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final m = items[i];
          return ListTile(
            title: Text('${m.type.name} • ${m.amount.toStringAsFixed(2)}'),
            subtitle: Text('${m.dayId} • ${m.createdAt.toIso8601String()}'
                '${m.note == null ? '' : '\n${m.note}'}'),
            trailing: Text(m.signedAmount.toStringAsFixed(2)),
          );
        },
      ),
    );
  }
}
