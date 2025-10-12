// lib/features/wallet/screens/wallet_screen.dart
import 'package:flutter/material.dart';

// Gate + الشارة
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

// يوم + محفظة
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';

// إضافة حركة (شاشة عمل)
import 'package:admiral_tablet_a/features/wallet/screens/add_wallet_movement_screen.dart';
// سجل الحركات (عرض فقط)
import 'package:admiral_tablet_a/features/wallet/screens/wallet_movements_screen.dart';

enum WalletQuickKind { deposit, withdraw, returnCash }

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _wallet = WalletController();
  final _day = DaySessionController();

  void _openAdd(WalletQuickKind kind) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddWalletMovementScreen(initialKind: kind),
      ),
    );
    if (ok == true && mounted) {
      // بعد الإضافة نعيد البناء لتحديث الرصيد
      setState(() {});
    }
  }

  void _openMovements() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WalletMovementsScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DaySessionGate(
      allowWhenClosed: true, // المحفظة متاحة دائمًا
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          actions: const [DayStatusIndicator()],
        ),
        body: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceHeader(wallet: _wallet, day: _day),
              const SizedBox(height: 16),
              _ActionsGrid(
                onDeposit: () => _openAdd(WalletQuickKind.deposit),
                onWithdraw: () => _openAdd(WalletQuickKind.withdraw),
                onReturn: () => _openAdd(WalletQuickKind.returnCash),
                onMovements: _openMovements,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  final WalletController wallet;
  final DaySessionController day;

  const _BalanceHeader({required this.wallet, required this.day});

  double get _totalAll =>
      wallet.items.fold(0.0, (s, e) => s + e.amount);

  double get _todayTotal {
    if (!(day.isOpen && day.current != null)) return 0.0;
    final id = day.current!.id;
    return wallet.items
        .where((e) => e.dayId == id)
        .fold(0.0, (s, e) => s + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current balance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _BalanceCard(
                title: 'Total',
                value: _fmt(_totalAll),
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: (day.isOpen && day.current != null) ? 1 : 0.6,
                child: _BalanceCard(
                  title: (day.isOpen && day.current != null)
                      ? 'This day'
                      : 'This day (closed)',
                  value: _fmt(_todayTotal),
                  color: cs.tertiary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'المجموع = كل الحركات (إيداع/سحب/مشتريات/مصاريف). '
              'رصيد اليوم يظهر فقط عند فتح يوم.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.outline),
        ),
      ],
    );
  }

  static String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    final rx = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(rx, (m) => ',');
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _BalanceCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onReturn;
  final VoidCallback onMovements;

  const _ActionsGrid({
    required this.onDeposit,
    required this.onWithdraw,
    required this.onReturn,
    required this.onMovements,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _ActionTile(
          icon: Icons.add_card,
          label: 'Deposit',
          onTap: onDeposit,
        ),
        _ActionTile(
          icon: Icons.outbond,
          label: 'Withdraw',
          onTap: onWithdraw,
        ),
        _ActionTile(
          icon: Icons.reply_all,
          label: 'Return cash',
          onTap: onReturn,
        ),
        _ActionTile(
          icon: Icons.receipt_long,
          label: 'Movements',
          onTap: onMovements,
        ),
      ],
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
