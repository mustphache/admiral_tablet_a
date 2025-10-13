import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement_model.dart';
import 'package:admiral_tablet_a/core/time/time_formats.dart';

class WalletMovementsScreen extends StatefulWidget {
  const WalletMovementsScreen({super.key});

  @override
  State<WalletMovementsScreen> createState() => _WalletMovementsScreenState();
}

class _WalletMovementsScreenState extends State<WalletMovementsScreen> {
  final _ctrl = WalletController();
  bool _loading = true;
  late String _dayId;
  List<WalletMovementModel> _items = const [];

  @override
  void initState() {
    super.initState();
    _dayId = TimeFmt.dayIdToday();
    _ctrl.load().then((_) {
      if (!mounted) return;
      _reload();
    });
  }

  Future<void> _reload() async {
    final list = _ctrl.items.where((e) => e.dayId == _dayId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wallet')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final total = _items.fold<double>(0, (s, e) => s + e.signedAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                '${total.toStringAsFixed(2)} دج: الرصيد',
                style: const TextStyle(fontWeight: FontWeight.w700),
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
            Center(child: Text('لا توجد حركات لليوم', style: TextStyle(color: cs.outline))),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(height: 4),
          itemBuilder: (_, i) => _ItemTile(_items[i]),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final WalletMovementModel m;
  const _ItemTile(this.m);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isPlus = m.signedAmount >= 0;
    final color = isPlus ? Colors.green : Colors.red;
    final icon = isPlus ? Icons.south_east : Icons.north_east;

    final date = m.createdAt.toLocal().toString().split('.').first;

    // تسمية ودّية حسب النوع
    final friendly = switch (m.type) {
      WalletType.credit => 'رصيد وارد',
      WalletType.refund => 'استرجاع نقدي',
      WalletType.purchase => 'شراء',
      WalletType.expense => 'مصروف',
    };

    final note = (m.note ?? '').trim();
    final title = note.isEmpty ? friendly : '$friendly — $note';

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        '${m.signedAmount.toStringAsFixed(2)} دج',
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
