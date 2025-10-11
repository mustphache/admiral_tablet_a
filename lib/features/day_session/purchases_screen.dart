import 'package:flutter/material.dart';
import '../../state/controllers/purchase_controller.dart';
import 'purchase_add_screen.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';

// ✅ Gate
import 'package:admiral_tablet_a/core/session/index.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State {
  final _ctrl = PurchaseController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    await _ctrl.restore();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const DaySessionGate(
        child: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final items = _ctrl.items.reversed.toList();
    final day = DaySessionController();

    return DaySessionGate(
      // Purchases تتقفل لما اليوم مغلق
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المشتريات'),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // فحص إضافي (حتى لو Gate موجود) لتجربة أوضح للمستخدم
            if (!day.isOpen) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اليوم مغلق - افتح يوم جديد أولاً')),
              );
              return;
            }

            final res = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PurchaseAddScreen()),
            );
            if (res != null) {
              await _ctrl.restore();
              if (!mounted) return;
              setState(() {});
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('إضافة'),
        ),
        body: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (context, i) {
            final e = items[i];
            return ListTile(
              title: Text(e.supplier ?? ''),
              subtitle: Text(e.tagNumber ?? ''),
              trailing: Text((e.total ?? e.price ?? 0).toStringAsFixed(2)),
            );
          },
        ),
      ),
    );
  }
}
