import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/sale.dart';
import '../../models/car.dart';
import '../../models/customer.dart';
import '../../models/installment.dart';

class InvoicePdf {
  static Future<pw.Font> _loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  static Future<void> printInvoice({
    required Sale sale,
    required Car car,
    Customer? customer,
    List<Installment> installments = const [],
    String companyName = 'معرض السيارات',
    String companyPhone = '',
    String companyAddress = '',
  }) async {
    final font = await _loadFont('assets/fonts/Cairo-Regular.ttf');
    final boldFont = await _loadFont('assets/fonts/Cairo-Bold.ttf');

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ✅ Header
              _buildHeader(
                  font, boldFont, companyName, companyPhone, companyAddress),
              pw.SizedBox(height: 20),
              pw.Divider(
                  thickness: 2, color: const PdfColor.fromInt(0xFFE94560)),
              pw.SizedBox(height: 16),

              // ✅ Invoice Title
              pw.Center(
                child: pw.Text(
                  'فاتورة بيع سيارة',
                  style: pw.TextStyle(font: boldFont, fontSize: 20),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'رقم الفاتورة: ${sale.id ?? ''}    التاريخ: ${sale.saleDate?.substring(0, 10) ?? ''}',
                  style: pw.TextStyle(
                      font: font, fontSize: 11, color: PdfColors.grey),
                ),
              ),
              pw.SizedBox(height: 20),

              // ✅ Customer + Car Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Car Info
                  pw.Expanded(
                    child: _buildInfoBox(
                      font: font,
                      boldFont: boldFont,
                      title: 'بيانات السيارة',
                      items: [
                        'الماركة والموديل: ${car.brand} ${car.model}',
                        'السنة: ${car.year ?? '-'}',
                        'اللون: ${car.color ?? '-'}',
                        'رقم اللوحة: ${car.plateNumber ?? '-'}',
                        'رقم الشاسيه: ${car.chassisNumber ?? '-'}',
                        'الكيلومترات: ${car.kilometers}',
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Customer Info
                  pw.Expanded(
                    child: _buildInfoBox(
                      font: font,
                      boldFont: boldFont,
                      title: 'بيانات العميل',
                      items: [
                        'الاسم: ${customer?.name ?? '-'}',
                        'الهاتف: ${customer?.phone ?? '-'}',
                        'العنوان: ${customer?.address ?? '-'}',
                        'الموظف: ${sale.employeeName ?? '-'}',
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // ✅ Payment Info
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF5F5F5),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border:
                      pw.Border.all(color: const PdfColor.fromInt(0xFFE94560)),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${sale.salePrice.toStringAsFixed(0)} ج',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 18,
                              color: const PdfColor.fromInt(0xFFE94560)),
                        ),
                        pw.Text('سعر البيع:',
                            style: pw.TextStyle(font: boldFont, fontSize: 14)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(_paymentLabel(sale.paymentType),
                            style: pw.TextStyle(font: font, fontSize: 12)),
                        pw.Text('طريقة الدفع:',
                            style: pw.TextStyle(font: font, fontSize: 12)),
                      ],
                    ),
                    if (sale.paymentType == 'installment') ...[
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${sale.paidAmount.toStringAsFixed(0)} ج',
                              style: pw.TextStyle(
                                  font: font,
                                  fontSize: 12,
                                  color: PdfColors.green)),
                          pw.Text('المدفوع:',
                              style: pw.TextStyle(font: font, fontSize: 12)),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              '${sale.remainingAmount.toStringAsFixed(0)} ج',
                              style: pw.TextStyle(
                                  font: font,
                                  fontSize: 12,
                                  color: PdfColors.orange)),
                          pw.Text('المتبقي:',
                              style: pw.TextStyle(font: font, fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ✅ Installments Table
              if (installments.isNotEmpty) ...[
                pw.Text('جدول الأقساط',
                    style: pw.TextStyle(font: boldFont, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFE94560)),
                      children: [
                        _tableCell('الحالة', boldFont, isHeader: true),
                        _tableCell('تاريخ الاستحقاق', boldFont, isHeader: true),
                        _tableCell('المبلغ', boldFont, isHeader: true),
                        _tableCell('رقم القسط', boldFont, isHeader: true),
                      ],
                    ),
                    // Rows
                    ...installments.asMap().entries.map((e) {
                      final inst = e.value;
                      final status = inst.paid
                          ? 'مدفوع ✓'
                          : inst.isOverdue
                              ? 'متأخر !'
                              : 'في الانتظار';
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: e.key.isEven
                              ? PdfColors.white
                              : const PdfColor.fromInt(0xFFF9F9F9),
                        ),
                        children: [
                          _tableCell(status, font),
                          _tableCell(inst.dueDate.substring(0, 10), font),
                          _tableCell(
                              '${inst.amount.toStringAsFixed(0)} ج', font),
                          _tableCell('${e.key + 1}', font),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              // ✅ Notes
              if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                pw.Text('ملاحظات:',
                    style: pw.TextStyle(font: boldFont, fontSize: 12)),
                pw.Text(sale.notes!,
                    style: pw.TextStyle(
                        font: font, fontSize: 11, color: PdfColors.grey700)),
                pw.SizedBox(height: 20),
              ],

              // ✅ Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                          width: 120, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('توقيع العميل',
                          style: pw.TextStyle(font: font, fontSize: 11)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                          width: 120, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('توقيع المدير',
                          style: pw.TextStyle(font: font, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    final customerName = (customer?.name ?? 'عميل').replaceAll(' ', '_');
    final date = sale.saleDate?.substring(0, 10) ??
        DateTime.now().toIso8601String().substring(0, 10);
    final fileName = 'فاتورة_${customerName}_$date';

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: fileName, // استخدم الاسم الديناميكي
    );
  }

  static pw.Widget _buildHeader(
    pw.Font font,
    pw.Font boldFont,
    String companyName,
    String phone,
    String address,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (phone.isNotEmpty)
              pw.Text('📞 $phone',
                  style: pw.TextStyle(font: font, fontSize: 11)),
            if (address.isNotEmpty)
              pw.Text('📍 $address',
                  style: pw.TextStyle(font: font, fontSize: 11)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(companyName,
                style: pw.TextStyle(font: boldFont, fontSize: 22)),
            pw.Text('معرض سيارات متكامل',
                style: pw.TextStyle(
                    font: font, fontSize: 12, color: PdfColors.grey)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoBox({
    required pw.Font font,
    required pw.Font boldFont,
    required String title,
    required List<String> items,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 13)),
          pw.Divider(color: PdfColors.grey300),
          ...items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: pw.Text(item,
                    style: pw.TextStyle(font: font, fontSize: 11)),
              )),
        ],
      ),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font,
      {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 11,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _paymentLabel(String? type) {
    switch (type) {
      case 'cash':
        return 'كاش';
      case 'transfer':
        return 'تحويل بنكي';
      case 'check':
        return 'شيك';
      case 'installment':
        return 'تقسيط';
      default:
        return '-';
    }
  }
}
