import 'package:flutter/material.dart';

// استخدمنا package imports لتفادي مشاكل المسارات
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/purchase_controller.dart';
import 'package:admiral_tablet_a/state/controllers/expense_controller.dart';
import 'package:admiral_tablet_a/common/helpers/utils.dart';

class ADaySummaryScreen extends StatefulWidget {
  const ADaySummaryScreen({super.key});

  @override
  State<ADaySummaryScreen> createState() => _ADaySummaryScreenState();
}

class _ADaySummaryScreenState extends State<ADaySummaryScreen> {
  final _dayCtrl = DaySessionController();
  final _pCtrl = PurchaseController();
  final _eCtrl = ExpenseController();

  bool _loading = true;

  late String _sessionId;
  double _openingCash = 0;
  double _purchasesTotal = 0;
  double _expensesTotal = 0;

  double get _balance => _openingCash - _purchasesTotal - _expensesTotal;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // استرجاع آخر حالة
    await _dayCtrl.restore();
    _pCtrl.restore();
    _eCtrl.restore();

    // تحديد sessionId: من الجلسة الحالية أو fallback إلى تاريخ اليوم
    _sessionId = _dayCtrl.current?.id ?? todayISO();
    _openingCash = _dayCtrl.current?.openingCash ?? 0;

    // حساب المجاميع
    _purchasesTotal = _pCtrl.totalForDay(_sessionId);
    _expensesTotal = _eCtrl.totalForDay(_sessionId);

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget tile(String title, String value, {IconData? icon}) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: ListTile(
          leading: icon != null ? Icon(icon) : null,
          title: Text(title),
          trailing: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('A ملخص يوم'),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() => _loading = true);
              await _load(); // إعادة حساب الأرقام
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          tile('جلسة', _sessionId, icon: Icons.today),
          tile('رصيد افتتاحي', '${_openingCash.toStringAsFixed(2)} دج',
              icon: Icons.account_balance_wallet),
          tile('إجمالي المشتريات', '${_purchasesTotal.toStringAsFixed(2)} دج',
              icon: Icons.shopping_bag),
          tile('إجمالي المصاريف', '${_expensesTotal.toStringAsFixed(2)} دج',
              icon: Icons.receipt_long),
          const Divider(),
          tile('الرصيد الحالي', '${_balance.toStringAsFixed(2)} دج',
              icon: Icons.balance),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilledButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context); // ✅ التقطناه قبل await
                  setState(() => _loading = true);

                  await _load();

                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('تم تحديث الملخص')),
                  );
                },
                icon: const Icon(Icons.summarize),
              label: const Text('تحديث الملخص'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
