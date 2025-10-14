import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/purchase_controller.dart';

class PurchaseAddScreen extends StatefulWidget {
  final PurchaseModel? edit;
  const PurchaseAddScreen({super.key, this.edit});

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

  late final DaySessionController _session;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _session = DaySessionController();
    _session.load().then((_) {
      if (!mounted) return;
      final m = widget.edit;
      if (m != null) {
        _supplier.text = m.supplier;
        _tagNumber.text = m.tagNumber ?? ''; // ✅ fix: String? → String
        _price.text = m.price.toStringAsFixed(2);
        _count.text = m.count.toString();
        _note.text = m.note ?? '';
      }
      setState(() => _loading = false);
    });
  }

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

    if (!_session.isOn || _session.current == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session OFF — فعّلها من الشاشة الرئيسية')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final double price = double.tryParse(_price.text.trim()) ?? 0;
      final int count = int.tryParse(_count.text.trim()) ?? 0;
      final double total = price * count;
      final String note = _note.text.trim();

      if (widget.edit == null) {
        final m = PurchaseModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          sessionId: _session.current!.id,
          supplier: _supplier.text.trim(),
          tagNumber: _tagNumber.text.trim().isEmpty ? null : _tagNumber.text.trim(),
          price: price,
          count: count,
          total: total,
          note: note.isEmpty ? null : note,
          timestamp: DateTime.now(),
        );
        await PurchaseController().add(m);
      } else {
        final old = widget.edit!;
        final updated = PurchaseModel(
          id: old.id,
          sessionId: old.sessionId,
          supplier: _supplier.text.trim(),
          tagNumber: _tagNumber.text.trim().isEmpty ? null : _tagNumber.text.trim(),
          price: price,
          count: count,
          total: total,
          note: note.isEmpty ? null : note,
          timestamp: old.timestamp,
        );

        // ✅ التوقيع الجديد: update(updated: ...)
        await PurchaseController().update(updated: updated);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.edit == null ? 'إضافة شراء' : 'تعديل شراء'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _session,
      child: Consumer<DaySessionController>(
        builder: (_, s, __) {
          final canWrite = s.isOn;

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.edit == null ? 'إضافة شراء' : 'تعديل شراء'),
            ),
            body: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (!canWrite)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Session OFF — القراءة فقط',
                          style: TextStyle(color: cs.outline)),
                    ),
                  TextFormField(
                    controller: _supplier,
                    decoration: const InputDecoration(labelText: 'المورد'),
                    textInputAction: TextInputAction.next,
                    enabled: canWrite,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل المورد' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tagNumber,
                    decoration: const InputDecoration(labelText: 'رقم الخاتم (اختياري)'),
                    textInputAction: TextInputAction.next,
                    enabled: canWrite,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _price,
                    decoration: const InputDecoration(labelText: 'السعر'),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    enabled: canWrite,
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
                    textInputAction: TextInputAction.done,
                    enabled: canWrite,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n <= 0) return 'أدخل عددًا صحيحًا';
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
                    enabled: canWrite,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: (!canWrite || _busy) ? null : _save,
                    icon: const Icon(Icons.save),
                    label:
                    _busy ? const Text('جارٍ الحفظ…') : const Text('حفظ'),
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
