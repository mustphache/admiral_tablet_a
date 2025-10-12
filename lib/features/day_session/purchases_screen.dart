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

  String get _todayId => TimeFmt.dayIdToday();

  void _reload() {
    _items = _ctrl.listByDay(_todayId);
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

          return Scaffold(
            appBar: AppBar(title: const Text('Purchases')),
            body: RefreshIndicator(
              onRefresh: () async => _reload(),
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
                itemBuilder: (_, i) => _PurchaseTile(_items[i]),
                separatorBuilder: (_, __) => const Divider(height: 4),
                itemCount: _items.length,
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
        Text((m.tagNumber ?? '').isNotEmpty ? 'خاتم: ${m.tagNumber}' : ''),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${m.total.toStringAsFixed(2)} دج',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('(${m.count} × ${m.price.toStringAsFixed(2)})',
              style: TextStyle(color: cs.outline, fontSize: 12)),
        ],
      ),
    );
  }
}
