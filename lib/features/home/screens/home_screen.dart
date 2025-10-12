import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';

import 'package:admiral_tablet_a/features/day_session/day_session_screen.dart';
import 'package:admiral_tablet_a/features/day_session/purchases_screen.dart';
import 'package:admiral_tablet_a/features/day_session/expenses_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/wallet_screen.dart';

import 'package:admiral_tablet_a/state/services/credit_inbox_store.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/core/time/time_formats.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      child: const _HomeScaffold(),
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIRAL — Tablet A'),
        actions: const [DayStatusIndicator()],
      ),
      body: const _HomeBody(),
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
    _inbox.load();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreditInboxStore>.value(
      value: _inbox,
      child: Consumer<DaySessionController>(
        builder: (_, session, __) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SessionSwitchCard(ctrl: session),
              const SizedBox(height: 12),
              _CreditBanner(canConfirm: session.isOn),
              const SizedBox(height: 8),
              const _HomeGrid(),
            ],
          );
        },
      ),
    );
  }
}

// -------- Session Switch (الوحيد) --------
class _SessionSwitchCard extends StatelessWidget {
  final DaySessionController ctrl;
  const _SessionSwitchCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final on = ctrl.isOn;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Icon(
          on ? Icons.toggle_on : Icons.toggle_off,
          size: 40,
          color: on ? Colors.green : cs.outline,
        ),
        title: Text(on ? 'Session ON' : 'Session OFF'),
        subtitle: Text(on
            ? 'الإضافة مفعّلة (مشتريات/مصاريف/محفظة)'
            : 'القراءة فقط — لا يمكن إضافة/تعديل/حذف'),
        trailing: Switch(
          value: on,
          onChanged: (v) async {
            if (v) {
              await ctrl.turnOn(actor: 'home');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تفعيل Session — الكتابة مفعّلة')),
                );
              }
            } else {
              await ctrl.turnOff(actor: 'home');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إيقاف Session — القراءة فقط')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

// -------- Credit Inbox Banner --------
class _CreditBanner extends StatelessWidget {
  final bool canConfirm;
  const _CreditBanner({required this.canConfirm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<CreditInboxStore>(
      builder: (_, inbox, __) {
        final total = inbox.pendingTotal;

        if (total <= 0) {
          if (kDebugMode) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.construction, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Dev: Inject incoming credit for testing',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _devAddCreditDialog(context),
                    icon: const Icon(Icons.add_card),
                    label: const Text('Inject credit (dev)'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }

        return Container(
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
                child: Text(
                  'رصيد وارد: ${total.toStringAsFixed(2)} دج — اضغط تأكيد لإضافته',
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: canConfirm
                    ? 'إضافة الرصيد للمحفظة'
                    : 'الكتابة مقفولة (Session OFF) — فعّلها من الشاشة الرئيسية',
                child: FilledButton.tonal(
                  onPressed: canConfirm
                      ? () async {
                    final wallet = WalletController();
                    final dayId = TimeFmt.dayIdToday();
                    await wallet.addCredit(
                      dayId: dayId,
                      amount: total,
                      note: 'Incoming credit (confirmed)',
                    );
                    await inbox.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت إضافة الرصيد إلى المحفظة')),
                      );
                    }
                  }
                      : null,
                  child: const Text('تأكيد'),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Inject more (dev)',
                  onPressed: () => _devAddCreditDialog(context),
                  icon: const Icon(Icons.add_card),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Future<void> _devAddCreditDialog(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Inject incoming credit (dev)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (DZD)',
                hintText: 'مثال: 200000',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final v = double.tryParse(amountCtrl.text.trim()) ?? 0;
      final note = noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim();
      if (v > 0) {
        final inbox = Provider.of<CreditInboxStore>(context, listen: false);
        await inbox.addPending(v, note: note);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Injected ${v.toStringAsFixed(2)} DZD (dev)')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid amount')),
          );
        }
      }
    }
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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

class PurchasesTile extends StatelessWidget {
  const PurchasesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DaySessionController>(
      builder: (_, session, __) {
        final locked = !session.isOn;
        return _HomeTile(
          icon: Icons.shopping_bag_outlined,
          label: 'Purchases',
          locked: locked,
          onTap: () {
            if (locked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Session OFF — فعّلها من الشاشة الرئيسية')),
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
    return Consumer<DaySessionController>(
      builder: (_, session, __) {
        final locked = !session.isOn;
        return _HomeTile(
          icon: Icons.receipt_long_outlined,
          label: 'Expenses',
          locked: locked,
          onTap: () {
            if (locked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Session OFF — فعّلها من الشاشة الرئيسية')),
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
      label: 'Session Info',
      locked: false,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DaySessionScreen()),
        );
      },
    );
  }
}

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
                    Text('Session OFF', style: TextStyle(fontSize: 12)),
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
