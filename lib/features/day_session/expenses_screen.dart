import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/features/day_session/expense_add_screen.dart';

// Placeholder للقائمة؛ اربطه بكنترولر بياناتك لاحقًا.

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      child: Consumer<DaySessionController>(
        builder: (_, session, __) {
          final cs = Theme.of(context).colorScheme;
          final canWrite = session.isOn;

          return Scaffold(
            appBar: AppBar(title: const Text('Expenses')),
            body: Column(
              children: [
                if (!canWrite)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline),
                        SizedBox(width: 8),
                        Expanded(child: Text('Session OFF — القراءة فقط')),
                      ],
                    ),
                  ),
                const Expanded(
                  child: _ExpensesListPlaceholder(),
                ),
              ],
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
                // أعد تحميل القائمة لو ok == true
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

class _ExpensesListPlaceholder extends StatelessWidget {
  const _ExpensesListPlaceholder();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        'قائمة المصاريف (عرض فقط الآن)\n— سيتم ربطها بالبيانات لاحقًا —',
        textAlign: TextAlign.center,
        style: TextStyle(color: cs.outline),
      ),
    );
  }
}

