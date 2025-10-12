import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/purchase_controller.dart';
import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import 'package:admiral_tablet_a/core/time/time_formats.dart';

import 'package:admiral_tablet_a/features/day_session/purchase_add_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final _ctrl = PurchaseController();
  List<PurchaseModel> _items = const [];
  bool _loading = true;

  String get _todayId => TimeFmt.dayIdToday();

  Future<void> _reload() async {
    _items = _ctrl.listByDay(_todayId);
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    PurchaseController().load().then((_) => mounted ? _reload() : null);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      child: Consumer<DaySessionController>(
        builder: (_, session, __) {
          final canWrite = session.isOn;
          final cs = Theme.of(context).colorScheme;

          if (_loading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Purchases')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Purchases')),
            body: RefreshIndicator(
              onRefresh: _reload,
              child: _items.isEmpty
                  ? ListView(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'لا توجد مشتريات لليوم.',
                      style: TextStyle(color: cs.outline),
                    ),
                  ),
                ],
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 4),
                itemBuilder: (_, i) {
                  final m = _items[i];
                  return Dismissible(
                    key: ValueKey('p_${m.id}'),
                    direction: canWrite
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                      color: cs.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.delete, color: cs.onErrorContainer),
                    ),
                    confirmDismiss: (_) async {
                      if (!canWrite) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Session OFF — الحذف ممنوع'),
                          ),
                        );
                        return false;
                      }
                      return await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('حذف شراء'),
                          content: const Text('تأكيد حذف هذه العملية؟ سيتم عكس أثرها على المحفظة.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('إلغاء'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('حذف'),
                            ),
                          ],
                        ),
                      ) ??
                          false;
                    },
                    onDismissed: (_) async {
                      await _ctrl.removeById(m.id);
                      await _reload();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم الحذف')),
                        );
                      }
                    },
                    child: InkWell(
                      onTap: () async {
                        if (!canWrite) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session OFF — التعديل ممنوع')),
                          );
                          return;
                        }
                        final ok = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => PurchaseAddScreen(edit: m),
                          ),
                        );
                        if (ok == true) _reload();
                      },
                      child: _PurchaseTile(m),
                    ),
                  );
                },
              ),
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

class _PurchaseTile extends StatelessWidget {
  final PurchaseModel m;
  const _PurchaseTile(this.m);

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
