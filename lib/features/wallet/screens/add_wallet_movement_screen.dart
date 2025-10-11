import 'package:flutter/material.dart';

// Gate + الشارة
import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';

// يوم ومحفظة
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement_model.dart';

enum WalletQuickKind { deposit, withdraw, returnCash }

class AddWalletMovementScreen extends StatefulWidget {
  final WalletQuickKind? initialKind;
  const AddWalletMovementScreen({super.key, this.initialKind});

  @override
  State<AddWalletMovementScreen> createState() => _AddWalletMovementScreenState();
}

class _AddWalletMovementScreenState extends State<AddWalletMovementScreen> {
  final _form = GlobalKey<FormState>();
  WalletQuickKind _kind = WalletQuickKind.deposit;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialKind != null) _kind = widget.initialKind!;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final raw = _amountCtrl.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw) ?? 0;
    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل مبلغًا صحيحًا')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final day = DaySessionController();
      final wallet = WalletController();

      // حدّد dayId: إن كان اليوم مفتوحًا استعمل الحالي، وإلاّ استخدم تاريخ اليوم كنص
      final dayId = day.isOpen && day.current != null
          ? day.current!.id
          : DateTime.now().toIso8601String().split('T').first;

      switch (_kind) {
        case WalletQuickKind.deposit:
        case WalletQuickKind.returnCash:
        // يدخل للمحفظة (موجب) — نستعمل refund كنمط إدخال
          await wallet.addRefund(dayId: dayId, amount: amount, note: note ?? (_kind == WalletQuickKind.deposit ? 'Deposit' : 'Return'));
          break;
        case WalletQuickKind.withdraw:
        // يخرج من المحفظة (سالب) — نستخدم adjust بسالب
          await wallet.addMovement(
            dayId: dayId,
            type: WalletType.adjust,
            amount: -amount.abs(),
            note: note ?? 'Withdraw',
          );
          break;
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر حفظ الحركة: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DaySessionGate(
      allowWhenClosed: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Wallet Movement'),
          actions: const [DayStatusIndicator()],
        ),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Deposit'),
                    selected: _kind == WalletQuickKind.deposit,
                    onSelected: (_) => setState(() => _kind = WalletQuickKind.deposit),
                  ),
                  ChoiceChip(
                    label: const Text('Withdraw'),
                    selected: _kind == WalletQuickKind.withdraw,
                    onSelected: (_) => setState(() => _kind = WalletQuickKind.withdraw),
                  ),
                  ChoiceChip(
                    label: const Text('Return'),
                    selected: _kind == WalletQuickKind.returnCash,
                    onSelected: (_) => setState(() => _kind = WalletQuickKind.returnCash),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (DZD)',
                  hintText: 'مثال: 200000',
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'أدخل مبلغًا صحيحًا';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.save),
                label: _busy ? const Text('Saving…') : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
