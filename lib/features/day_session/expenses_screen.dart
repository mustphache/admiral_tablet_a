import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/expense_controller.dart';
import 'expense_add_screen.dart';

// ✅ Gate
import 'package:admiral_tablet_a/core/session/index.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State {
  final _ctrl = ExpenseController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    await _ctrl.restore();
    if (mounted) setState(() => _loading = false);
  }

  Future _add() async {
    final day = DaySessionController().current;
    if (day == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('افتح جلسة اليوم أولاً')),
      );
      return;
    }

    final added = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ExpenseAddScreen(),
      ),
    );
    if (added == true) {
      await _ctrl.restore();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const DaySessionGate(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final items = _ctrl.items.reversed.toList();

    return DaySessionGate(
      // Expenses تتقفل لما اليوم مغلق
      child: Scaffold(
        appBar: AppBar(title: const Text('Expenses')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        body: items.isEmpty
            ? const Center(child: Text('No expenses yet'))
            : ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (context, i) {
            final e = items[i];
            return ListTile(
              leading: const Icon(Icons.money_off),
              title: Text(e.kind ?? 'نوع المصروف؟'),
              subtitle: Text(e.note ?? ''),
              trailing:
              Text('${(e.amount ?? 0).toStringAsFixed(2)} دج'),
              onLongPress: () async {
                final ok = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete expense?'),
                    content:
                    const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await _ctrl.delete(e.id ?? '');
                  if (mounted) setState(() {});
                }
              },
            );
          },
        ),
      ),
    );
  }
}
