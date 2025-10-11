import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/data/models/expense_model.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/expense_controller.dart';

// ✅ Gate للنظام
import 'package:admiral_tablet_a/core/session/index.dart';

class ExpenseAddScreen extends StatefulWidget {
  const ExpenseAddScreen({super.key});

  @override
  State createState() => _ExpenseAddScreenState();
}

class _ExpenseAddScreenState extends State {
  final _form = GlobalKey<FormState>();

  final _kind = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _kind.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final day = DaySessionController();

      // حماية إضافية: منع الحفظ إذا اليوم مغلق (زيادة على Gate)
      if (!day.isOpen) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اليوم مغلق — افتح يوم جديد أولًا')),
        );
        return;
      }

      final amount = double.tryParse(_amount.text.trim()) ?? 0;
      final m = ExpenseModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sessionId: day.current!.id, // مهم جدًا
        kind: _kind.text.trim(),
        amount: amount,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        timestamp: DateTime.now(),
      );

      await ExpenseController().add(m);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل حفظ المصروف: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ لف الشاشة بالـGate (تُمنع تلقائيًا إذا اليوم مغلق)
    return DaySessionGate(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة مصروف'),
        ),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              TextFormField(
                controller: _kind,
                decoration: const InputDecoration(labelText: 'النوع'),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'أدخل النوع' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                decoration: const InputDecoration(labelText: 'المبلغ'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'أدخل مبلغًا صحيحًا';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                decoration:
                const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.save),
                label: _busy
                    ? const Text('جارٍ الحفظ…')
                    : const Text('حفظ'),
              ),
              const SizedBox(height: 8),
              if (_busy)
                LinearProgressIndicator(
                  backgroundColor: cs.surfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
