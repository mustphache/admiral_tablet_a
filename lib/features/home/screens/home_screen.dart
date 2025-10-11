// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/ui/widgets/app_scaffold.dart';

// جلسة اليوم (Gate + مؤشر الحالة)
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

// الشاشات التي سننقل إليها
import 'package:admiral_tablet_a/features/day_session/day_session_screen.dart';
import 'package:admiral_tablet_a/features/day_session/purchases_screen.dart';
import 'package:admiral_tablet_a/features/day_session/expenses_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/wallet_screen.dart';

// ✅ صندوق الرصيد الوارد
import 'package:admiral_tablet_a/state/services/credit_inbox_store.dart';
// ✅ محفظة
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نخلي الـHome متاحة دايمًا، ونوفر الـProvider لمؤشر الحالة والـtiles
    return DaySessionGate(
      allowWhenClosed: true,
      child: AppScaffold(
        title: 'ADMIRAL — Tablet A',
        actions: const [DayStatusIndicator()],
        body: const _HomeBody(),
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final _inbox = CreditInboxStore();

  @override
  void initState() {
    super.initState();
    _inbox.load(); // حمل الصندوق
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreditInboxStore>.value(
      value: _inbox,
      child: Column(
        children: const [
          _CreditBanner(),  // ⬅️ الشريط الجديد
          Expanded(child: _HomeGrid()),
        ],
      ),
    );
  }
}

class _CreditBanner extends StatelessWidget {
  const _CreditBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<CreditInboxStore>(
      builder: (_, inbox, __) {
        final total = inbox.pendingTotal;
        if (total <= 0) {
          // لا يوجد رصيد وارد معلّق
          return const SizedBox(height: 8);
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('رصيد وارد: ${total.toStringAsFixed(2)} دج — تأكيد لإضافته'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: () async {
                  final dayCtrl = DaySessionController();
                  final wallet = WalletController();

                  if (dayCtrl.isOpen && dayCtrl.current != null) {
                    // اليوم مفتوح -> أضف كرَصيد للمحفظة تحت dayId الحالي
                    await wallet.addCredit(
                      dayId: dayCtrl.current!.id,
                      amount: total,
                      note: 'Incoming credit (confirmed)',
                    );
                  }
                  // امسح الصندوق (في كل الأحوال)
                  await inbox.clear();

                  if (Navigator.canPop(context)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تأكيد الرصيد الوارد')),
                    );
                  }
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: 2,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      children: const [
        PurchasesTile(),
        ExpensesTile(),
        WalletTile(),
        EndOfDayTile(),
      ],
    );
  }
}

// -------- Tiles --------

class PurchasesTile extends StatelessWidget {
  const PurchasesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DaySessionStore>(
      builder: (_, store, __) {
        final locked = !store.state.isOpen;
        return _HomeTile(
          icon: Icons.shopping_bag_outlined,
          label: 'Purchases',
          locked: locked,
          onTap: () {
            if (locked) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DaySessionScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('افتح اليوم أولاً لإضافة مشتريات')),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PurchasesScreen()),
              );
            }
          },
        );
      },
    );
  }
}

class ExpensesTile extends StatelessWidget {
  const ExpensesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DaySessionStore>(
      builder: (_, store, __) {
        final locked = !store.state.isOpen;
        return _HomeTile(
          icon: Icons.receipt_long_outlined,
          label: 'Expenses',
          locked: locked,
          onTap: () {
            if (locked) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DaySessionScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('افتح اليوم أولاً لتسجيل مصروف')),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExpensesScreen()),
              );
            }
          },
        );
      },
    );
  }
}

class WalletTile extends StatelessWidget {
  const WalletTile({super.key});

  @override
  Widget build(BuildContext context) {
    // المحفظة مفتوحة دائمًا
    return _HomeTile(
      icon: Icons.account_balance_wallet_outlined,
      label: 'Wallet',
      locked: false,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WalletScreen()),
        );
      },
    );
  }
}

class EndOfDayTile extends StatelessWidget {
  const EndOfDayTile({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeTile(
      icon: Icons.flag_circle_outlined,
      label: 'End of day',
      locked: false,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DaySessionScreen()),
        );
      },
    );
  }
}

// -------- Generic tile with "locked" visual --------

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool locked;
  final VoidCallback onTap;

  const _HomeTile({
    required this.icon,
    required this.label,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = locked ? cs.surfaceVariant : cs.surface;
    final border = cs.outlineVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(label),
              if (locked) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lock_outline, size: 16),
                    SizedBox(width: 4),
                    Text('افتح اليوم أولاً', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
