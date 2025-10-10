import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/purchase_controller.dart';


class PurchaseAddScreen extends StatefulWidget {
  const PurchaseAddScreen({super.key});

  @override
  State<PurchaseAddScreen> createState() => _PurchaseAddScreenState();
}

class _PurchaseAddScreenState extends State<PurchaseAddScreen> {
  final _form = GlobalKey<FormState>();

  final _supplier = TextEditingController();
  final _tagNumber = TextEditingController();
  final _price = TextEditingController();
  final _count = TextEditingController();
  final _note = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _supplier.dispose();
    _tagNumber.dispose();
    _price.dispose();
    _count.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      final day = DaySessionController();

      // حماية: لا تسمح بالحفظ إذا اليوم مغلق
      if (!day.isOpen) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اليوم مغلق — افتح يوم جديد أولًا')),
        );
        return;
      }

      final price = double.tryParse(_price.text.trim()) ?? 0;
      final count = int.tryParse(_count.text.trim()) ?? 0;
      final total = price * count;

      final m = PurchaseModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sessionId: day.current!.id, // مهم جدًا
        supplier: _supplier.text.trim(),
        tagNumber: _tagNumber.text.trim(),
        price: price,
        count: count,
        total: total,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        timestamp: DateTime.now(),
      );

      await PurchaseController().add(m);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل حفظ الشراء: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة شراء'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TextFormField(
              controller: _supplier,
              decoration: const InputDecoration(labelText: 'المورّد'),
              textInputAction: TextInputAction.next,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'أدخل المورّد' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagNumber,
              decoration: const InputDecoration(labelText: 'رقم الكاتم'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'السعر'),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'أدخل سعرًا صحيحًا';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _count,
              decoration: const InputDecoration(labelText: 'العدد'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'أدخل عددًا صحيحًا';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
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
            if (_busy)
              LinearProgressIndicator(
                backgroundColor: cs.surfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
