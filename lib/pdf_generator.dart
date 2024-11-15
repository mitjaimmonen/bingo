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
  final pw.MemoryImage? backgroundImage;

  final String? backsideText;
  final pw.MemoryImage? backsideImage;

  PdfGenerator({
    required this.entries,
    this.gridSize = 5,
    required this.title,
    required this.description,
    required this.bingosPerPage,
    required this.bingoCount,
    this.backgroundImage,
    this.backsideText,
    this.backsideImage,
  });

  Future<pw.Document> generatePdf() async {
    final pdf = pw.Document();
    final random = Random();

    final pageFormat = _getPageFormat(bingosPerPage);
    final pages = (bingoCount / bingosPerPage).ceil();
    final rows = sqrt(bingosPerPage).toInt();
    final cols = (bingosPerPage / rows).ceil();

    for (int i = 0; i < pages; i++) {
      // front side
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(0),
          pageFormat: pageFormat,
          build: (context) {
            return pw.GridView(
              crossAxisCount: cols,
              children: List.generate(bingosPerPage, (index) {
                final shuffledEntries = List<String>.from(entries)
                  ..shuffle(random);

                return _buildBingo(
                  context,
                  shuffledEntries,
                  bingosPerPage,
                  backgroundImage: backgroundImage,
                  title: title,
                  description: description,
                  rows: rows,
                  cols: cols,
                );
              }),
            );
          },
        ),
      );

      if (backsideText != null || backsideImage != null) {
        // back side
        pdf.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(0),
            pageFormat: pageFormat,
            build: (context) {
              return pw.GridView(
                crossAxisCount: cols,
                children: List.generate(
                  bingosPerPage,
                  (index) {
                    return pw.Stack(
                      children: [
                        if (backsideImage != null)
                          pw.Positioned.fill(
                            child: pw.Image(
                              backsideImage!,
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        pw.Center(
                          child: pw.Text(
                            backsideText!,
                            style: pw.TextStyle(
                              fontSize: 48 / sqrt(bingosPerPage),
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red800,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      }
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

  pw.Widget _buildBingo(
    pw.Context context,
    List<String> entries,
    int bingosPerPage, {
    pw.MemoryImage? backgroundImage,
    String? title,
    String? description,
    int? rows,
    int? cols,
  }) {
    final table = pw.Table(
      tableWidth: pw.TableWidth.min,
      border: pw.TableBorder.all(
        color: PdfColors.green800,
        width: 4 / sqrt(bingosPerPage),
      ),
      children: List.generate(
        gridSize,
        (row) {
          return pw.TableRow(
            children: List.generate(gridSize, (col) {
              final index = row * gridSize + col;
              return pw.Container(
                width: 80 / sqrt(bingosPerPage),
                height: 80 / sqrt(bingosPerPage),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  index < entries.length ? entries[index] : '',
                  textAlign: pw.TextAlign.center,
                ),
              );
            }),
          );
        },
      ),
    );

    return pw.Stack(
      children: [
        if (backgroundImage != null)
          pw.Positioned.fill(
            child: pw.Image(
              backgroundImage,
              fit: pw.BoxFit.cover,
            ),
          ),
        pw.Column(
          children: [
            pw.SizedBox(height: 96 / (rows ?? 1)),
            if (title != null)
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 48 / sqrt(bingosPerPage),
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red800,
                ),
                textAlign: pw.TextAlign.center,
              ),
            if (description != null)
              pw.Text(
                description,
                style: pw.TextStyle(
                  fontSize: 24 / sqrt(bingosPerPage),
                  color: PdfColors.red800,
                ),
                textAlign: pw.TextAlign.center,
              ),
            pw.Expanded(
                child: pw.Align(
              alignment: pw.Alignment.bottomCenter,
              child: table,
            )),
            pw.SizedBox(height: 96 / (rows ?? 1)),
          ],
        ),
      ],
    );
  }
}
