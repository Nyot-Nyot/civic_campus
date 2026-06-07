import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RabPdfService {
  static Future<Uint8List> generate({
    required String docNumber,
    required String incidentTitle,
    required String location,
    required String category,
    required String technicianName,
    required List<Map<String, dynamic>> items,
    required double totalCost,
    required String staffName,
    int version = 1,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'RENCANA ANGGARAN BIAYA',
              style: pw.TextStyle(
                font: pw.Font.courier(),
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              docNumber,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Insiden', incidentTitle),
                pw.SizedBox(height: 4),
                _infoRow('Lokasi', location),
                pw.SizedBox(height: 4),
                _infoRow('Kategori', category),
                pw.SizedBox(height: 4),
                _infoRow('Teknisi', technicianName),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            children: [
              _tableRow(['No', 'Deskripsi', 'Qty', 'Satuan', 'Harga Satuan', 'Total'], isHeader: true),
              ...items.asMap().entries.map((entry) {
                final i = entry.key + 1;
                final item = entry.value;
                final desc = item['description'] as String? ?? '';
                final qty = (item['qty'] as num?)?.toInt() ?? 0;
                final unit = item['unit'] as String? ?? '';
                final cost = (item['unit_cost'] as num?)?.toDouble() ?? 0;
                final total = qty * cost;
                return _tableRow([
                  '$i.',
                  desc,
                  '$qty',
                  unit,
                  _formatRupiah(cost),
                  _formatRupiah(total),
                ]);
              }),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
              color: PdfColors.grey100,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.SizedBox(width: 48),
                pw.Text(
                  _formatRupiah(totalCost),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _signatureBlock('Teknisi', staffName),
              _signatureBlock('Mengetahui,\nFacility Admin', ''),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 72,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        pw.Text(' : ', style: pw.TextStyle(fontSize: 10)),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  static pw.TableRow _tableRow(List<String> cells, {bool isHeader = false}) {
    return pw.TableRow(
      children: cells.asMap().entries.map((entry) {
        final i = entry.key;
        final alignment = (i == 0)
            ? pw.Alignment.centerRight
            : (i >= 2 ? pw.Alignment.centerRight : pw.Alignment.centerLeft);

        return pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          alignment: alignment,
          decoration: isHeader
              ? pw.BoxDecoration(color: PdfColors.grey200)
              : null,
          child: pw.Text(
            entry.value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _signatureBlock(String title, String name) {
    return pw.Column(
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
        pw.SizedBox(height: 48),
        pw.Text(name, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
      ],
    );
  }

  static String _formatRupiah(double amount) {
    final parts = amount.toStringAsFixed(0);
    final result = StringBuffer();
    int count = 0;
    for (int i = parts.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(parts[i]);
      count++;
    }
    return 'Rp ${result.toString().split('').reversed.join()}';
  }

  static Future<void> share({
    required String docNumber,
    required String incidentTitle,
    required String location,
    required String category,
    required String technicianName,
    required List<Map<String, dynamic>> items,
    required double totalCost,
    required String staffName,
    int version = 1,
  }) async {
    final pdfBytes = await generate(
      docNumber: docNumber,
      incidentTitle: incidentTitle,
      location: location,
      category: category,
      technicianName: technicianName,
      items: items,
      totalCost: totalCost,
      staffName: staffName,
      version: version,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'RAB_$docNumber.pdf',
    );
  }
}
