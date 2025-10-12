import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement_model.dart';

/// شاشة إضافة حركة محفظة (بسطة + تعمل مع WalletQuickKind بدون استيراده)
class AddWalletMovementScreen extends StatefulWidget {
  /// نقبل أي نوع هنا لتفادي اختلاف enum بين الملفات
  final Object? initialKind; // WalletQuickKind? من wallet_screen.dart
  const AddWalletMovementScreen({super.key, this.initialKind});

  @override
  State<AddWalletMovementScreen> createState() => _AddWalletMovementScreenState();
}

class _AddWalletMovementScreenState extends State<AddWalletMovementScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _fmtDay = DateFormat('yyyy-MM-dd');

  // deposit | withdraw | returnCash
  String _kind = 'deposit';

  final _wallet = WalletController();
  final _day = DaySessionController();

  @override
  void initState() {
    super.initState();
    _kind = _resolveInitialKind(widget.initialKind);
  }

  String _resolveInitialKind(Object? k) {
    final s = (k ?? '').toString().toLowerCase();
    if (s.contains('withdraw')) return 'withdraw';
    if (s.contains('return')) return 'returnCash';
    return 'deposit';
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل مبلغًا صحيحًا')),
      );
      return;
    }

    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();

    final dayId = (_day.isOpen && _day.current != null)
        ? _day.current!.id
        : _fmtDay.format(DateTime.now()); // خارج الجلسة

    WalletMovementModel created;

    if (_kind == 'deposit') {
      created = await _wallet.addCredit(dayId: dayId, amount: amount, note: note ?? 'Deposit');
    } else if (_kind == 'withdraw') {
      // سحب بسيط من الرصيد → نسجله كخصم مصروف (−)
      created = await _wallet.addSpendExpense(dayId: dayId, amount: amount, note: note ?? 'Withdraw');
    } else {
      // returnCash
      created = await _wallet.addRefund(dayId: dayId, amount: amount, note: note ?? 'Return cash');
    }

    if (!mounted) return;
    Navigator.of(context).pop(true); // رجّع true للتحديث في الشاشة السابقة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add wallet movement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _KindPicker(
            value: _kind,
            onChanged: (v) => setState(() => _kind = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (DZD)',
              hintText: 'مثال: 200000',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _KindPicker extends StatelessWidget {
  final String value; // deposit | withdraw | returnCash
  final ValueChanged<String> onChanged;
  const _KindPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Deposit'),
          selected: value == 'deposit',
          onSelected: (_) => onChanged('deposit'),
        ),
        ChoiceChip(
          label: const Text('Withdraw'),
          selected: value == 'withdraw',
          onSelected: (_) => onChanged('withdraw'),
        ),
        ChoiceChip(
          label: const Text('Return cash'),
          selected: value == 'returnCash',
          onSelected: (_) => onChanged('returnCash'),
        ),
      ],
    );
  }
}
