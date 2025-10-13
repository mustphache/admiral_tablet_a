import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/core/time/time_formats.dart';

// لو عندك enum مشترك للأنواع السريعة:
enum WalletQuickKind { credit, withdraw, returnCash }

class AddWalletMovementScreen extends StatefulWidget {
  const AddWalletMovementScreen({super.key});

  @override
  State<AddWalletMovementScreen> createState() => _AddWalletMovementScreenState();
}

class _AddWalletMovementScreenState extends State<AddWalletMovementScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  WalletQuickKind _kind = WalletQuickKind.credit;
  bool _busy = false;

  late final DaySessionController _session;

  @override
  void initState() {
    super.initState();
    _session = DaySessionController();
    _session.load();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      final amt = double.tryParse(_amount.text.trim()) ?? 0;
      final note = _note.text.trim();
      // نستخدم dayId الحالي؛ لو ماكانش Session، نستعمل تاريخ اليوم
      final dayId = (_session.current?.id ?? TimeFmt.dayIdToday());

      switch (_kind) {
        case WalletQuickKind.credit:
        // زيادة الرصيد (موجب)
          await WalletController().addCredit(
            dayId: dayId,
            amount: amt,
            note: note.isEmpty ? 'رصيد وارد' : note,
          );
          break;

        case WalletQuickKind.withdraw:
        // ✅ سحب: يُسجَّل كمصروف (سالب)
          await WalletController().addSpendExpense(
            dayId: dayId,
            amount: amt,
            note: note.isEmpty ? 'سحب نقدي' : note,
          );
          break;

        case WalletQuickKind.returnCash:
        // إرجاع للمحفظة (موجب)
          await WalletController().addRefund(
            dayId: dayId,
            amount: amt,
            note: note.isEmpty ? 'استرجاع نقدي' : note,
          );
          break;
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<DaySessionController>.value(
      value: _session,
      child: Consumer<DaySessionController>(
        builder: (_, s, __) {
          return Scaffold(
            appBar: AppBar(title: const Text('حركة محفظة')),
            body: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  SegmentedButton<WalletQuickKind>(
                    segments: const [
                      ButtonSegment(
                        value: WalletQuickKind.credit,
                        label: Text('إضافة رصيد'),
                        icon: Icon(Icons.south_east),
                      ),
                      ButtonSegment(
                        value: WalletQuickKind.withdraw,
                        label: Text('سحب'),
                        icon: Icon(Icons.north_east),
                      ),
                      ButtonSegment(
                        value: WalletQuickKind.returnCash,
                        label: Text('استرجاع'),
                        icon: Icon(Icons.reply),
                      ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (v) => setState(() => _kind = v.first),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amount,
                    decoration: const InputDecoration(labelText: 'المبلغ'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final n = double.tryParse((v ?? '').trim());
                      if (n == null || n <= 0) return 'أدخل مبلغًا صحيحًا';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _note,
                    decoration: const InputDecoration(labelText: 'ملاحظة (اختياري)'),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.save),
                    label: _busy ? const Text('جارٍ الحفظ…') : const Text('حفظ'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ملاحظة: السحب يُسجَّل كمصروف وينقص الرصيد، بينما الإضافة/الاسترجاع يزيدان الرصيد.',
                    style: TextStyle(color: cs.outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
