import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/ui/app_routes.dart';

// Gate + الشارة
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

// شاشة إضافة حركة (سنمرّر نوعًا ابتدائيًا)
import 'package:admiral_tablet_a/features/wallet/screens/add_wallet_movement_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _openAdd(BuildContext context, WalletQuickKind kind) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddWalletMovementScreen(initialKind: kind),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DaySessionGate(
      allowWhenClosed: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          actions: const [DayStatusIndicator()],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _ActionTile(
                    icon: Icons.add_card,
                    label: 'Deposit',
                    onTap: () => _openAdd(context, WalletQuickKind.deposit),
                  ),
                  _ActionTile(
                    icon: Icons.outbond,
                    label: 'Withdraw',
                    onTap: () => _openAdd(context, WalletQuickKind.withdraw),
                  ),
                  _ActionTile(
                    icon: Icons.reply_all,
                    label: 'Return cash',
                    onTap: () => _openAdd(context, WalletQuickKind.returnCash),
                  ),
                  _ActionTile(
                    icon: Icons.receipt_long,
                    label: 'Movements',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.walletMovements),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
