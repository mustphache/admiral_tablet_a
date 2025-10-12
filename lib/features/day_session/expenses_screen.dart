import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/expense_controller.dart';
import 'package:admiral_tablet_a/data/models/expense_model.dart';
import 'package:admiral_tablet_a/core/time/time_formats.dart';

import 'package:admiral_tablet_a/features/day_session/expense_add_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _ctrl = ExpenseController();
  List<ExpenseModel> _items = const [];

  String get _todayId => TimeFmt.dayIdToday();

  void _reload() {
    final all = _ctrl.items; // نفترض نفس نمط Wallet/Purchase
    _items = all.where((e) => e.sessionId == _todayId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
          final canWrite = session.isOn;
          final cs = Theme.of(context).colorScheme;

          final total = _items.fold<double>(0, (s, e) => s + e.amount);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Expenses'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      'المجموع: ${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: _items.isEmpty
                  ? ListView(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'لا توجد مصاريف لليوم.',
                      style: TextStyle(color: cs.outline),
                    ),
                  ),
                ],
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (_, i) => _ExpenseTile(_items[i]),
                separatorBuilder: (_, __) => const Divider(height: 4),
                itemCount: _items.length,
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add expense'),
              onPressed: canWrite
                  ? () async {
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const ExpenseAddScreen(),
                  ),
                );
                if (ok == true) _reload();
              }
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session OFF — فعّلها من الشاشة الرئيسية'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel m;
  const _ExpenseTile(this.m);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date =
        m.timestamp.toLocal().toString().split('.').first; // عرض مختصر

    return ListTile(
      leading: const Icon(Icons.receipt_long_outlined),
      title: Text(m.kind.isEmpty ? '—' : m.kind),
      subtitle: Text('ت: $date'),
      trailing: Text('${m.amount.toStringAsFixed(2)} دج',
          style: const TextStyle(fontWeight: FontWeight.w600)),
      tileColor: cs.surface,
    );
  }
}
