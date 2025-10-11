import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/common/helpers/utils.dart';
import 'package:admiral_tablet_a/ui/widgets/app_scaffold.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/purchase_controller.dart';
import 'package:admiral_tablet_a/state/controllers/expense_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/common/helpers/snapshot_service.dart';
import 'package:admiral_tablet_a/state/services/outbox_service.dart';
import 'package:admiral_tablet_a/data/models/outbox_item_model.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement_model.dart';
import 'package:admiral_tablet_a/data/models/day_session_model.dart';

// ✅ session system
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

class DaySessionScreen extends StatefulWidget {
  const DaySessionScreen({super.key});

  @override
  State<DaySessionScreen> createState() => _DaySessionScreenState();
}

class _DaySessionScreenState extends State<DaySessionScreen> {
  final _form = GlobalKey<FormState>();
  final _marketCtrl = TextEditingController();
  final _cashCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _ctrl = DaySessionController();
  final _pCtrl = PurchaseController();
  final _eCtrl = ExpenseController();
  final _wallet = WalletController();
  final _snapshot = SnapshotService();
  final _outbox = OutboxService();

  bool _busy = true;
  double _sumPurchases = 0;
  double _sumExpenses = 0;

  double get _currentBalance =>
      (_ctrl.current?.openingCash ?? 0) - _sumPurchases - _sumExpenses;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    // sync gate state
    await DaySessionStore().load();

    await _ctrl.restore();
    final s = _ctrl.current;
    if (s != null) {
      _marketCtrl.text = s.market;
      _cashCtrl.text = s.openingCash.toStringAsFixed(2);
      _notesCtrl.text = s.notes ?? '';
    }
    await _refreshTotals();
    setState(() => _busy = false);
  }

  Future _open() async {
    if (!_form.currentState!.validate()) return;

    final market = _marketCtrl.text.trim();
    final opening =
        double.tryParse(_cashCtrl.text.replaceAll(',', '.')) ?? 0;
    final notes =
    _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    setState(() => _busy = true);

    final wasOpen = _ctrl.isOpen;
    final prevOpening = _ctrl.current?.openingCash ?? 0;

    await _ctrl.openSession(
      market: market,
      openingCash: opening,
      notes: notes,
    );

    if (!wasOpen) {
      await _wallet.addMovement(
        dayId: _ctrl.current!.id,
        type: WalletType.open,
        amount: opening,
        note: 'Opening cash',
      );
    } else if (opening != prevOpening) {
      final delta = opening - prevOpening;
      if (delta != 0) {
        await _wallet.addMovement(
          dayId: _ctrl.current!.id,
          type: WalletType.adjust,
          amount: delta,
          note: 'Opening cash adjusted',
        );
      }
    }

    await DaySessionStore().openDay();

    await _refreshTotals();
    setState(() => _busy = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم فتح اليوم/تحديثه')));
  }

  Future _close() async {
    final id = _ctrl.current?.id ?? todayISO();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('تأكيد إغلاق اليوم'),
        content: Text('سيتم حفظ تقرير اليوم "$id" ولن يمكن تعديله لاحقًا.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('تأكيد')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      final json = await _snapshot.buildDayJson(
        day: _ctrl,
        purchases: _pCtrl,
        expenses: _eCtrl,
      );

      await _outbox.add(OutboxItemModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        kind: 'snapshot',
        dayId: id,
        payload: {'data': json},
        createdAt: DateTime.now().toUtc(),
      ));

      await _wallet.addMovement(
        dayId: id,
        type: WalletType.adjust,
        amount: _currentBalance,
        note: 'End of day balance',
      );

      await _ctrl.closeSession();
      await DaySessionStore().closeDay();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إغلاق اليوم وحفظ التقرير')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الإغلاق: $e')),
        );
      }
    } finally {
      await _refreshTotals();
      setState(() => _busy = false);
    }
  }

  Future _wipe() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('مسح بيانات الجلسة؟'),
        content: const Text('سيتم حذف بيانات اليوم من هذا الجهاز فقط.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('تأكيد')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);

    await _ctrl.wipeSession();
    _marketCtrl.clear();
    _cashCtrl.clear();
    _notesCtrl.clear();
    _sumPurchases = 0;
    _sumExpenses = 0;

    await DaySessionStore().closeDay();

    setState(() => _busy = false);
  }

  Future _refreshTotals() async {
    final sessionId =
        _ctrl.current?.id ?? DateTime.now().toIso8601String().split('T').first;

    await _pCtrl.restore();
    await _eCtrl.restore();

    _sumPurchases = _pCtrl.totalForDay(sessionId);
    _sumExpenses = _eCtrl.totalForDay(sessionId);

    if (mounted) setState(() {});
  }

  Widget _summaryCard() {
    final opening = _ctrl.current?.openingCash ?? 0;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ملخص سريع',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('رصيد افتتاحي')),
                Text('${opening.toStringAsFixed(2)} دج'),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text('إجمالي المشتريات')),
                Text('${_sumPurchases.toStringAsFixed(2)} دج'),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text('إجمالي المصاريف')),
                Text('${_sumExpenses.toStringAsFixed(2)} دج'),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text('الرصيد الحالي',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text(
                  '${_currentBalance.toStringAsFixed(2)} دج',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _refreshTotals,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث الملخص'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = _ctrl.current?.id;

    return AppScaffold(
      title: 'جلسة اليوم',
      actions: const [DayStatusIndicator()],
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تاريخ اليوم: ${id ?? todayISO()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marketCtrl,
                decoration: const InputDecoration(
                  labelText: 'السوق / الوجهة',
                  hintText: 'مثال: سوق الثلاثاء',
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'أدخل اسم السوق' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cashCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'رأس مال البداية (دج)',
                  hintText: 'مثال: 1500000',
                ),
                validator: (v) {
                  final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (x == null) return 'قيمة غير صحيحة';
                  if (x < 0) return 'لا يمكن أن يكون سالبًا';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration:
                const InputDecoration(labelText: 'ملاحظات (اختياري)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _busy ? null : _open,
                  child: Text(_ctrl.isOpen ? 'تحديث اليوم' : 'فتح اليوم'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (!_ctrl.isOpen || _busy) ? null : _close,
                      icon: const Icon(Icons.flag_circle),
                      label: const Text('إغلاق اليوم'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _wipe,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('مسح البيانات'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_ctrl.current != null) _summaryCard(),
            ],
          ),
        ),
      ),
    );
  }
}
