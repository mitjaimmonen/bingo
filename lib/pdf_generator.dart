import 'dart:math';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  final List<String> entries;
  final int gridSize;
  final String title;
  final String description;
  final int bingosPerPage;
  final int bingoCount;

  PdfGenerator({
    required this.entries,
    this.gridSize = 5,
    required this.title,
    required this.description,
    required this.bingosPerPage,
    required this.bingoCount,
  });

  Future<pw.Document> generatePdf() async {
    final pdf = pw.Document();
    final random = Random();

    final pageFormat = _getPageFormat(bingosPerPage);
    final pages = (bingoCount / bingosPerPage).ceil();
    final rows = sqrt(bingosPerPage).toInt();
    final cols = (bingosPerPage / rows).ceil();

    for (int i = 0; i < pages; i++) {
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(0),
          pageFormat: pageFormat,
          build: (context) {
            return pw.GridView(
              childAspectRatio: 1,
              crossAxisCount: cols,
              children: List.generate(bingosPerPage, (index) {
                final shuffledEntries = List<String>.from(entries)
                  ..shuffle(random);

                return _buildBingoTable(
                    context, shuffledEntries, bingosPerPage);
              }),
            );
          },
        ),
      );
    }

    return pdf;
  }

  PdfPageFormat _getPageFormat(int bingosPerPage) {
    switch (bingosPerPage) {
      case 1:
      case 4:
      case 16:
        return PdfPageFormat.a4;
      case 2:
      case 8:
        return PdfPageFormat.a4.landscape;
      default:
        return PdfPageFormat.a4;
    }
  }

  pw.Widget _buildBingoTable(
      pw.Context context, List<String> entries, int bingosPerPage) {
    return pw.Table(
      tableWidth: pw.TableWidth.min,
      border: pw.TableBorder.all(),
      children: List.generate(gridSize, (row) {
        return pw.TableRow(
          children: List.generate(gridSize, (col) {
            final index = row * gridSize + col;
            return pw.Container(
              width: 100 / sqrt(bingosPerPage),
              height: 100 / sqrt(bingosPerPage),
              alignment: pw.Alignment.center,
              child: pw.Text(
                index < entries.length ? entries[index] : '',
                textAlign: pw.TextAlign.center,
              ),
            );
          }),
        );
      }),
    );
  }
}
