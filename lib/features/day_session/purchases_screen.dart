import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/features/day_session/purchase_add_screen.dart';

// لو عندك موديل/لودر للقائمة الفعلية استورده واستعمله هنا.
// مؤقتًا نعرض Placeholder للقائمة.

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      child: Consumer<DaySessionController>(
        builder: (_, session, __) {
          final cs = Theme.of(context).colorScheme;
          final canWrite = session.isOn;

          return Scaffold(
            appBar: AppBar(title: const Text('Purchases')),
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
                  child: _PurchasesListPlaceholder(),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add purchase'),
              onPressed: canWrite
                  ? () async {
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const PurchaseAddScreen(),
                  ),
                );
                // هنا تقدر تعيد تحميل القائمة لو ok == true
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

class _PurchasesListPlaceholder extends StatelessWidget {
  const _PurchasesListPlaceholder();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        'قائمة المشتريات (عرض فقط الآن)\n— سيتم ربطها بالبيانات لاحقًا —',
        textAlign: TextAlign.center,
        style: TextStyle(color: cs.outline),
      ),
    );
  }
}
