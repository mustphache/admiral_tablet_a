// lib/features/wallet/screens/add_wallet_movement_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement_model.dart';
import 'package:admiral_tablet_a/data/models/wallet_quick_kind.dart';

class AddWalletMovementScreen extends StatefulWidget {
  final WalletQuickKind? initialKind;
  const AddWalletMovementScreen({super.key, this.initialKind});

  @override
  State<AddWalletMovementScreen> createState() => _AddWalletMovementScreenState();
}

class _AddWalletMovementScreenState extends State<AddWalletMovementScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _fmtDay = DateFormat('yyyy-MM-dd');

  late WalletQuickKind _kind;
  final _wallet = WalletController();

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind ?? WalletQuickKind.deposit;
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
    final dayId = _fmtDay.format(DateTime.now());

    WalletMovementModel created;
    if (_kind == WalletQuickKind.deposit) {
      created = await _wallet.addCredit(dayId: dayId, amount: amount, note: note ?? 'Deposit');
    } else if (_kind == WalletQuickKind.withdraw) {
      created = await _wallet.addSpendExpense(dayId: dayId, amount: amount, note: note ?? 'Withdraw');
    } else {
      created = await _wallet.addRefund(dayId: dayId, amount: amount, note: note ?? 'Return cash');
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      child: Consumer<DaySessionController>(
        builder: (_, session, __) {
          final canWrite = session.isOn;
          return Scaffold(
            appBar: AppBar(title: const Text('Add wallet movement')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!canWrite)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Session OFF — هذه الشاشة في وضع القراءة فقط. فعّل Session من الشاشة الرئيسية.'),
                  ),
                _KindPicker(
                  value: _kind,
                  onChanged: canWrite ? (v) => setState(() => _kind = v) : null,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountCtrl,
                  enabled: canWrite,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (DZD)',
                    hintText: 'مثال: 200000',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteCtrl,
                  enabled: canWrite,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                ),
                const SizedBox(height: 20),
                Tooltip(
                  message: canWrite
                      ? 'حفظ الحركة'
                      : 'الكتابة مقفولة (Session OFF) — فعّلها من الشاشة الرئيسية',
                  child: FilledButton.icon(
                    onPressed: canWrite ? _save : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KindPicker extends StatelessWidget {
  final WalletQuickKind value;
  final ValueChanged<WalletQuickKind>? onChanged;
  const _KindPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Deposit'),
          selected: value == WalletQuickKind.deposit,
          onSelected: onChanged == null ? null : (_) => onChanged!(WalletQuickKind.deposit),
        ),
        ChoiceChip(
          label: const Text('Withdraw'),
          selected: value == WalletQuickKind.withdraw,
          onSelected: onChanged == null ? null : (_) => onChanged!(WalletQuickKind.withdraw),
        ),
        ChoiceChip(
          label: const Text('Return cash'),
          selected: value == WalletQuickKind.returnCash,
          onSelected: onChanged == null ? null : (_) => onChanged!(WalletQuickKind.returnCash),
        ),
      ],
    );
  }
}
