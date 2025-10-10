// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/ui/app_routes.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _day = DaySessionController();

  @override
  void initState() {
    super.initState();
    _day.addListener(_onChanged);
  }

  @override
  void dispose() {
    _day.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _navGuard(BuildContext context, String route) async {
    // يمنع الدخول عند إغلاق اليوم
    if (_day.isOpen) {
      if (!mounted) return;
      Navigator.of(context).pushNamed(route);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اليوم مغلق — افتح يوم جديد أولاً')),
    );
  }

  Future<void> _closeDay(BuildContext context) async {
    if (!_day.isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد يوم مفتوح حالياً')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('تأكيد إغلاق اليوم'),
        content: Text(
          'هل تريد إقفال اليوم الحالي (${_day.current?.id ?? "-"})؟\n'
              'لن يمكن تعديل البيانات بعد الإغلاق.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await _day.closeSession();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إغلاق اليوم بنجاح')),
    );
    setState(() {});
  }

  Widget _bigTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: color ?? cs.surface,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 84,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final open = _day.isOpen;
    final id = _day.current?.id ?? '-';
    final market = _day.current?.market ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIRAL — Tablet A'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة حالة اليوم + زر Start/End day (يفتح شاشة الجلسة)
            Card(
              child: ListTile(
                leading: Icon(open ? Icons.lock_open : Icons.lock_outline),
                title: Text(open ? 'حالة اليوم: مفتوح' : 'حالة اليوم: مغلق'),
                subtitle: Text(
                  open ? 'السوق: $market — ID: $id' : 'افتح اليوم لبدء الإدخال',
                ),
                trailing: FilledButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.of(context).pushNamed(AppRoutes.daySession);
                  },
                  child: Text(open ? 'End day' : 'Start day'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // الصف الأول: Purchases / Expenses
            Row(
              children: [
                Expanded(
                  child: _bigTile(
                    title: 'Purchases',
                    icon: Icons.shopping_bag,
                    onTap: () => _navGuard(context, AppRoutes.purchases),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bigTile(
                    title: 'Expenses',
                    icon: Icons.receipt_long,
                    onTap: () => _navGuard(context, AppRoutes.expenses),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // الصف الثاني: Wallet / End of day
            Row(
              children: [
                Expanded(
                  child: _bigTile(
                    title: 'Wallet',
                    icon: Icons.account_balance_wallet,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.wallet),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bigTile(
                    title: 'End of day',
                    icon: Icons.flag_circle,
                    color: open
                        ? cs.primaryContainer.withValues(alpha: 0.2)
                        : cs.surface,
                    onTap: () => _closeDay(context),
                  ),
                ),
              ],
            ),

            const Spacer(),
            Text(
              open
                  ? 'يمكنك إضافة المشتريات والمصاريف قبل إغلاق اليوم.'
                  : 'ابدأ يومًا جديدًا لبدء الإدخال.',
              style: TextStyle(color: cs.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
