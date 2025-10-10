import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import 'package:admiral_tablet_a/common/helpers/utils.dart'; // todayISO()
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/purchase_controller.dart';
import 'package:admiral_tablet_a/state/controllers/expense_controller.dart';
import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import 'package:admiral_tablet_a/data/models/expense_model.dart';

import 'package:admiral_tablet_a/features/day_session/report_pdf.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _dayCtrl = DaySessionController();
  final _pCtrl = PurchaseController();
  final _eCtrl = ExpenseController();

  final _df = DateFormat('yyyy-MM-dd');

  String _dayId = todayISO();
  bool _loading = false;

  // KPIs
  double _openingCash = 0;
  double _purchasesTotal = 0;
  double _expensesTotal = 0;
  int _purchasesCount = 0;
  int _expensesCount = 0;

  double get _balance => _openingCash - _purchasesTotal - _expensesTotal;

  Future<Directory?> _androidDownloadsDir() async {
    try {
      final dirs =
      await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (dirs != null && dirs.isNotEmpty) return dirs.first;
    } catch (_) {}
    return null;
  }

  Future<Uint8List> _buildPdfBytes() async {
    final List<PurchaseModel> purchases = await _pCtrl.getByDay(_dayId);
    final List<ExpenseModel> expenses = await _eCtrl.getByDay(_dayId);

    final opening = _dayCtrl.current?.openingCash ?? 0;
    final purchasesTotal = purchases.fold<double>(
      0,
          (s, p) => s + (p.total ?? (p.price ?? 0)),
    );
    final expensesTotal = expenses.fold<double>(
      0,
          (s, e) => s + (e.amount ?? 0),
    );
    final balance = opening - purchasesTotal - expensesTotal;

    _openingCash = opening;
    _purchasesTotal = purchasesTotal;
    _expensesTotal = expensesTotal;
    _purchasesCount = purchases.length;
    _expensesCount = expenses.length;

    final data = ReportPdfData(
      dayId: _dayId,
      market: (_dayCtrl.current?.id == _dayId) ? (_dayCtrl.current?.market ?? '') : '',
      openingCash: opening,
      purchases: purchases,
      expenses: expenses,
      purchasesTotal: purchasesTotal,
      expensesTotal: expensesTotal,
      balance: balance,
    );

    return buildDayReportPdf(data);
  }

  Future<void> _shareOnly(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      final bytes = await _buildPdfBytes();
      await Printing.sharePdf(bytes: bytes, filename: 'report-$_dayId.pdf');
      messenger.showSnackBar(const SnackBar(content: Text('تمت مشاركة PDF بنجاح')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('فشل مشاركة PDF: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveOnly(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      final bytes = await _buildPdfBytes();
      final dir = await _androidDownloadsDir();
      if (dir == null) {
        messenger.showSnackBar(const SnackBar(content: Text('تعذّر العثور على مجلد التنزيلات')));
      } else {
        final file = File('${dir.path}/report-$_dayId.pdf');
        await file.writeAsBytes(bytes);
        messenger.showSnackBar(SnackBar(content: Text('تم الحفظ: ${file.path}')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_dayId) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() => _dayId = _df.format(picked));
  }

  @override
  Widget build(BuildContext context) {
    final closed = !DaySessionController().isOpen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقارير اليوم'),
        actions: [
          IconButton(
            tooltip: 'اختيار يوم',
            onPressed: _pickDay,
            icon: const Icon(Icons.calendar_today),
          ),
          IconButton(
            tooltip: 'حفظ PDF',
            onPressed: _loading ? null : () => _saveOnly(context),
            icon: _loading
                ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download),
          ),
          IconButton(
            tooltip: 'مشاركة PDF',
            onPressed: _loading ? null : () => _shareOnly(context),
            icon: const Icon(Icons.ios_share),
          ),
          // زر إقفال اليوم
          IconButton(
            tooltip: closed ? 'اليوم مُغلق' : 'إقفال اليوم',
            onPressed: closed
                ? null
                : () async {
              setState(() => _loading = true);
              try {
                await DaySessionController().closeSession();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إقفال اليوم')),
                );
                setState(() {});
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فشل إقفال اليوم: $e')),
                );
              } finally {
                if (!mounted) return;
                setState(() => _loading = false);
              }
            },
            icon: Icon(closed ? Icons.lock : Icons.lock_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          if (closed)
            Card(
              color: Colors.red.withValues(alpha:0.08),
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('اليوم مغلق'),
                subtitle: Text('الحالة: ${DaySessionController().isOpen ? 'مفتوح' : 'مغلق'}'),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.today),
              title: const Text('اليوم'),
              subtitle: Text(_dayId),
            ),
          ),
          const SizedBox(height: 8),
          _kpi('رصيد الافتتاح', _openingCash, Icons.account_balance_wallet),
          _kpi('إجمالي المشتريات ($_purchasesCount)', _purchasesTotal, Icons.shopping_bag),
          _kpi('إجمالي المصاريف ($_expensesCount)', _expensesTotal, Icons.receipt_long),
          _kpi('الرصيد النهائي', _balance, Icons.balance),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loading ? null : () => _saveOnly(context),
                  icon: const Icon(Icons.download),
                  label: const Text('حفظ PDF'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : () => _shareOnly(context),
                  icon: const Icon(Icons.ios_share),
                  label: const Text('مشاركة PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpi(String label, double value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value.toStringAsFixed(2)),
      ),
    );
  }
}
