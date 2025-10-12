import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/purchase_controller.dart';
import 'package:admiral_tablet_a/state/controllers/expense_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/core/time/time_formats.dart';

class ADaySummaryScreen extends StatefulWidget {
  const ADaySummaryScreen({super.key});

  @override
  State<ADaySummaryScreen> createState() => _ADaySummaryScreenState();
}

class _ADaySummaryScreenState extends State<ADaySummaryScreen> {
  final _p = PurchaseController();
  final _e = ExpenseController();
  final _w = WalletController();

  late String _dayId;
  double _purchasesTotal = 0;
  double _expensesTotal = 0;
  double _walletTotal = 0;

  void _reload() {
    _dayId = TimeFmt.dayIdToday();
    _purchasesTotal = _p.totalForDay(_dayId);
    _expensesTotal = _e.totalForDay(_dayId);
    _walletTotal = _w.totalForDay(_dayId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      child: Consumer<DaySessionController>(
        builder: (_, session, __) {
          final cs = Theme.of(context).colorScheme;
          final on = session.isOn;

          return Scaffold(
            appBar: AppBar(
              title: const Text('ملخص اليوم'),
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Chip(
                    label: Text(on ? 'ON' : 'OFF'),
                    avatar: CircleAvatar(
                      radius: 6,
                      backgroundColor: on ? Colors.green : cs.outline,
                    ),
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryCard(
                    title: 'إجمالي المشتريات',
                    value: _purchasesTotal,
                    icon: Icons.shopping_bag_outlined,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'إجمالي المصاريف',
                    value: _expensesTotal,
                    icon: Icons.receipt_long_outlined,
                    color: cs.tertiary,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'رصيد المحفظة (اليوم)',
                    value: _walletTotal,
                    icon: Icons.account_balance_wallet_outlined,
                    color: cs.secondary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'اليوم: $_dayId',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          '${value.toStringAsFixed(2)} دج',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        tileColor: cs.surface,
      ),
    );
  }
}
