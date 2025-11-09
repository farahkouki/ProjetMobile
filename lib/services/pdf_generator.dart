// lib/services/pdf_generator.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/voyage.dart';

class PdfGenerator {
  static Future<void> generatePdf(Voyage voyage) async {
    final pdf = pw.Document();

    // DONNÉES À METTRE DANS LE QR CODE (SCANNABLE PAR TOUT LE MONDE)
    final qrData = '''
VOYAGE CONFIRMÉ
Destination: ${voyage.destination}
Départ: ${DateFormat('dd/MM/yyyy').format(voyage.dateDepart)}
Retour: ${DateFormat('dd/MM/yyyy').format(voyage.dateArrivee)}
Budget: ${voyage.budget.toStringAsFixed(0)} TND
${voyage.description.isNotEmpty ? 'Notes: ${voyage.description}' : ''}
ID: ${voyage.uuid}
https://gestion-voyages.app/voyage/${voyage.uuid}
    '''.trim();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text("BILLET DE VOYAGE", style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)),
              pw.SizedBox(height: 40),

              // Cadre principal
              pw.Container(
                padding: const pw.EdgeInsets.all(25),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.indigo, width: 4),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Column(
                  children: [
                    _buildRow("Destination", voyage.destination),
                    _buildRow("Départ", DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(voyage.dateDepart)),
                    _buildRow("Retour", DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(voyage.dateArrivee)),
                    _buildRow("Budget", "${voyage.budget.toStringAsFixed(0)} TND"),
                    if (voyage.description.isNotEmpty) _buildRow("Notes", voyage.description),
                    pw.SizedBox(height: 30),

                    // QR CODE SCANNABLE À 1000%
                    pw.Center(
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: qrData,
                        width: 250,
                        height: 250,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Center(
                      child: pw.Text(
                        "Scannez pour voir les détails",
                        style: const pw.TextStyle(fontSize: 14, color: PdfColors.indigo800),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 40),
              pw.Text("gestion-voyages.app - 2025", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            ],
          ),
        ),
      ),
    );

    try {
      final dir = await getExternalStorageDirectory() ?? await getTemporaryDirectory();
      final file = File("${dir.path}/voyage_${voyage.uuid.substring(0, 8)}.pdf");
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) {
      print("Erreur PDF : $e");
    }
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text("$label :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}