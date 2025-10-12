import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement_model.dart';
import 'package:admiral_tablet_a/core/time/time_formats.dart';

import 'add_wallet_movement_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _wallet = WalletController();
  List<WalletMovementModel> _items = const [];
  bool _loading = true;

  String get _todayId => TimeFmt.dayIdToday();

  double get _totalToday =>
      _items.fold(0.0, (s, e) => s + (e.dayId == _todayId ? e.amount : 0.0));

  Future<void> _reload() async {
    final all = _wallet.items;
    _items = all.where((e) => e.dayId == _todayId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    // ✅ حمّل حركات المحفظة قبل العرض
    WalletController().load().then((_) => mounted ? _reload() : null);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      child: Consumer<DaySessionController>(
        builder: (_, session, __) {
          final canWrite = session.isOn;

          if (_loading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Wallet')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Wallet'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      'الرصيد: ${_totalToday.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _reload,
              child: _items.isEmpty
                  ? ListView(
                children: const [
                  SizedBox(height: 40),
                  Center(child: Text('لا توجد حركات اليوم.')),
                ],
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 4),
                itemBuilder: (_, i) => _WalletRow(_items[i]),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add movement'),
              onPressed: canWrite
                  ? () async {
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const AddWalletMovementScreen(),
                  ),
                );
                if (ok == true) _reload();
              }
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                    Text('Session OFF — فعّلها من الشاشة الرئيسية'),
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

class _WalletRow extends StatelessWidget {
  final WalletMovementModel m;
  const _WalletRow(this.m);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date = m.createdAt.toLocal().toString().split('.').first;
    final sign = m.amount >= 0 ? '+' : '−';

    return ListTile(
      leading: Icon(
        m.amount >= 0 ? Icons.call_received : Icons.call_made,
        color: m.amount >= 0 ? Colors.green : Colors.red,
      ),
      title: Text(m.note ?? m.type.name),
      subtitle: Text('ت: $date'),
      trailing: Text(
        '$sign${m.amount.abs().toStringAsFixed(2)} دج',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: m.amount >= 0 ? Colors.green : cs.error,
        ),
      ),
    );
  }
}
