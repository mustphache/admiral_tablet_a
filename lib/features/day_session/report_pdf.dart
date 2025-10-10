import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:admiral_tablet_a/data/models/purchase_model.dart';
import 'package:admiral_tablet_a/data/models/expense_model.dart';

class ReportPdfData {
  final String dayId;
  final String market;
  final double openingCash;
  final List<PurchaseModel> purchases;
  final List<ExpenseModel> expenses;
  final double purchasesTotal;
  final double expensesTotal;
  final double balance;

  const ReportPdfData({
    required this.dayId,
    required this.market,
    required this.openingCash,
    required this.purchases,
    required this.expenses,
    required this.purchasesTotal,
    required this.expensesTotal,
    required this.balance,
  });
}

Future<Uint8List> buildDayReportPdf(ReportPdfData d) async {
  final pdf = pw.Document();

  String fmtNum(num v) => v.toStringAsFixed(2);

  pw.Widget kpi(String label, String value) => pw.Container(
    padding: const pw.EdgeInsets.all(6),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: .7),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );

  pw.Widget table({
    required String title,
    required List<List<String>> rows,
    List<String>? headers,
    Map<int, pw.TableColumnWidth>? widths,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: rows,
          headerDecoration:
          const pw.BoxDecoration(color: PdfColors.blueGrey800),
          headerStyle: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: widths,
        ),
      ],
    );
  }

  // بدون count: نستخدم total وإذا غير موجود نرجّع price كإجمالي
  final purchaseRows = d.purchases.map((p) {
    final total = p.total ?? (p.price ?? 0);
    return <String>[
      p.tagNumber ?? '',
      p.supplier ?? '',
      fmtNum(p.price ?? 0),
      fmtNum(total),
      p.note ?? '',
      (p.timestamp ?? DateTime.now()).toString().substring(11, 16),
    ];
  }).toList();

  final expenseRows = d.expenses.map((e) {
    return <String>[
      e.kind ?? '',
      fmtNum(e.amount ?? 0),
      e.note ?? '',
      (e.timestamp ?? DateTime.now()).toString().substring(11, 16),
    ];
  }).toList();

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => [
        pw.Text('تقارير اليوم',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('اليوم: ${d.dayId}'),
        if (d.market.isNotEmpty) pw.Text('السوق: ${d.market}'),
        pw.SizedBox(height: 12),
        pw.Column(children: [
          kpi('رصيد الافتتاح', '${fmtNum(d.openingCash)} دج'),
          pw.SizedBox(height: 4),
          kpi('إجمالي المشتريات', '${fmtNum(d.purchasesTotal)} دج'),
          pw.SizedBox(height: 4),
          kpi('إجمالي المصاريف', '${fmtNum(d.expensesTotal)} دج'),
          pw.SizedBox(height: 4),
          kpi('الرصيد النهائي', '${fmtNum(d.balance)} دج'),
        ]),
        pw.SizedBox(height: 16),

        // جدول المشتريات (بدون عمود الكمية)
        table(
          title: 'تفاصيل المشتريات',
          headers: const ['Tag', 'Supplier', 'Price', 'Total', 'Note', 'Time'],
          widths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(1.4),
            3: pw.FlexColumnWidth(1.6),
            4: pw.FlexColumnWidth(3),
            5: pw.FlexColumnWidth(1.4),
          },
          rows: purchaseRows,
        ),

        pw.SizedBox(height: 12),

        table(
          title: 'تفاصيل المصاريف',
          headers: const ['Kind', 'Amount', 'Note', 'Time'],
          widths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(4),
            3: pw.FlexColumnWidth(1.4),
          },
          rows: expenseRows,
        ),
      ],
    ),
  );

  return pdf.save();
}
