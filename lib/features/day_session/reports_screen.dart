import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/purchase_controller.dart';
import 'package:admiral_tablet_a/state/controllers/expense_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/core/time/time_formats.dart';
import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import 'package:admiral_tablet_a/data/models/expense_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _p = PurchaseController();
  final _e = ExpenseController();
  final _w = WalletController();

  late String _dayId;
  List<PurchaseModel> _purchases = const [];
  List<ExpenseModel> _expenses = const [];
  double _purchasesTotal = 0;
  double _expensesTotal = 0;
  double _walletTotal = 0;

  void _reload() {
    _dayId = TimeFmt.dayIdToday();
    _purchases = _p.listByDay(_dayId);
    _expenses = _e.listByDay(_dayId);
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

          return Scaffold(
            appBar: AppBar(
              title: const Text('تقارير اليوم'),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Text(
                      '$_dayId',
                      style: TextStyle(color: cs.outline),
                    ),
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _HeaderTotals(
                    purchases: _purchasesTotal,
                    expenses: _expensesTotal,
                    wallet: _walletTotal,
                  ),
                  const SizedBox(height: 16),
                  Text('المشتريات (${_purchases.length})',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (_purchases.isEmpty)
                    _Empty('لا توجد مشتريات.')
                  else
                    ..._purchases
                        .map((m) => _PurchaseRow(m))
                        .toList(growable: false),
                  const SizedBox(height: 16),
                  Text('المصاريف (${_expenses.length})',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (_expenses.isEmpty)
                    _Empty('لا توجد مصاريف.')
                  else
                    ..._expenses
                        .map((m) => _ExpenseRow(m))
                        .toList(growable: false),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderTotals extends StatelessWidget {
  final double purchases;
  final double expenses;
  final double wallet;

  const _HeaderTotals({
    required this.purchases,
    required this.expenses,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _TotalChip('مشتريات', purchases, Icons.shopping_bag_outlined, cs.primary),
        const SizedBox(width: 8),
        _TotalChip('مصاريف', expenses, Icons.receipt_long_outlined, cs.tertiary),
        const SizedBox(width: 8),
        _TotalChip('محفظة', wallet, Icons.account_balance_wallet_outlined, cs.secondary),
      ],
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _TotalChip(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  final PurchaseModel m;
  const _PurchaseRow(this.m);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date = m.timestamp.toLocal().toString().split('.').first;
    return ListTile(
      leading: const Icon(Icons.shopping_bag_outlined),
      title: Text(m.supplier.isEmpty ? '—' : m.supplier),
      subtitle: Text(
        'ت: $date${(m.tagNumber ?? '').isNotEmpty ? ' • خاتم: ${m.tagNumber}' : ''}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${m.total.toStringAsFixed(2)} دج',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Text('(${m.count} × ${m.price.toStringAsFixed(2)})',
              style: TextStyle(color: cs.outline, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final ExpenseModel m;
  const _ExpenseRow(this.m);

  @override
  Widget build(BuildContext context) {
    final date = m.timestamp.toLocal().toString().split('.').first;
    return ListTile(
      leading: const Icon(Icons.receipt_long_outlined),
      title: Text(m.kind.isEmpty ? '—' : m.kind),
      subtitle: Text('ت: $date'),
      trailing: Text(
        '${m.amount.toStringAsFixed(2)} دج',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty(this.message);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(message, style: TextStyle(color: cs.outline)),
    );
  }
}
