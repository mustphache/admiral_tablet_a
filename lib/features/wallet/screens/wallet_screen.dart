// lib/features/wallet/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Gate + الشارة
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

// يوم + محفظة
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';

// SSOT: المال
import 'package:admiral_tablet_a/core/money/money.dart';

// إضافة حركة + سجل الحركات
import 'package:admiral_tablet_a/data/models/wallet_quick_kind.dart';
import 'package:admiral_tablet_a/features/wallet/screens/add_wallet_movement_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/wallet_movements_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _wallet = WalletController();

  void _openAdd(BuildContext context, WalletQuickKind kind) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddWalletMovementScreen(initialKind: kind),
      ),
    );
    if (ok == true && mounted) setState(() {});
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
      allowWhenClosed: true, // عرض دائمًا
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          actions: const [DayStatusIndicator()],
        ),
        body: ChangeNotifierProvider<DaySessionController>(
          create: (_) => DaySessionController()..load(),
          child: Consumer<DaySessionController>(
            builder: (_, session, __) {
              final canWrite = session.isOn;
              return RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _BalanceHeader(wallet: _wallet),
                    const SizedBox(height: 16),
                    _ActionsGrid(
                      canWrite: canWrite,
                      onDeposit: () => _openAdd(context, WalletQuickKind.deposit),
                      onWithdraw: () => _openAdd(context, WalletQuickKind.withdraw),
                      onReturn: () => _openAdd(context, WalletQuickKind.returnCash),
                      onMovements: _openMovements,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  final WalletController wallet;
  const _BalanceHeader({required this.wallet});

  double get _totalAll => wallet.items.fold(0.0, (s, e) => s + e.amount);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current balance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _BalanceCard(
          title: 'Total',
          value: Money.fmt(_totalAll),
          color: cs.primary,
        ),
        const SizedBox(height: 4),
        Text(
          'المجموع = كل الحركات (إيداع/سحب/مشتريات/مصاريف).',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.outline),
        ),
      ],
    );
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
  final bool canWrite;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onReturn;
  final VoidCallback onMovements;

  const _ActionsGrid({
    required this.canWrite,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onReturn,
    required this.onMovements,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget _tile(IconData icon, String label, VoidCallback onTap,
        {bool enabled = true}) {
      final locked = !enabled;
      final body = InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
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
                Icon(icon, size: 36, color: locked ? cs.outline : null),
                const SizedBox(height: 8),
                Text(label,
                    style: TextStyle(color: locked ? cs.outline : null)),
                if (locked) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock_outline, size: 14),
                      SizedBox(width: 4),
                      Text('Session OFF', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );

      return locked
          ? Tooltip(
        message: 'الكتابة مقفولة (Session OFF) — فعّلها من الشاشة الرئيسية',
        child: body,
      )
          : body;
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _tile(Icons.add_card, 'Deposit', onDeposit, enabled: canWrite),
        _tile(Icons.outbond, 'Withdraw', onWithdraw, enabled: canWrite),
        _tile(Icons.reply_all, 'Return cash', onReturn, enabled: canWrite),
        _tile(Icons.receipt_long, 'Movements', onMovements, enabled: true),
      ],
    );
  }
}
