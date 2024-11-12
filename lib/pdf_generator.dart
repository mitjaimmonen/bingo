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
    final shuffledEntries = List<String>.from(entries)..shuffle(random);

    final pageFormat = _getPageFormat(bingosPerPage);
    final pages = (bingoCount / bingosPerPage).ceil();

    for (int i = 0; i < pages; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title,
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(description, style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),
                _buildBingoTables(context, shuffledEntries, i),
              ],
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

  pw.Widget _buildBingoTables(
      pw.Context context, List<String> entries, int pageIndex) {
    final startIndex = pageIndex * bingosPerPage * gridSize * gridSize;

    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(bingosPerPage, (index) {
        final bingoStartIndex = startIndex + index * gridSize * gridSize;
        final bingoEndIndex =
            min(bingoStartIndex + gridSize * gridSize, entries.length);

        List<String> bingoEntries;
        if (bingoStartIndex < entries.length) {
          bingoEntries = entries.sublist(bingoStartIndex, bingoEndIndex);
        } else {
          bingoEntries = [];
        }

        // Fill remaining cells with empty strings if the list is too short
        while (bingoEntries.length < gridSize * gridSize) {
          bingoEntries.add('');
        }

        return _buildBingoTable(context, bingoEntries);
      }),
    );
  }

  pw.Widget _buildBingoTable(pw.Context context, List<String> entries) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: List.generate(gridSize, (row) {
        return pw.TableRow(
          children: List.generate(gridSize, (col) {
            final index = row * gridSize + col;
            return pw.Container(
              width: 50,
              height: 50,
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
