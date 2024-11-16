import 'dart:math';

import 'package:bingo/bloc/pdf_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  final PdfData pdfData;

  final int rows;
  final int cols;
  final double bingosPerPageSqrt;

  PdfGenerator({
    required this.pdfData,
  })  : rows = sqrt(pdfData.bingosPerPage).toInt(),
        cols = (pdfData.bingosPerPage / sqrt(pdfData.bingosPerPage).toInt())
            .ceil(),
        bingosPerPageSqrt = sqrt(pdfData.bingosPerPage);

  Future<pw.Document> generatePdf() async {
    final pdf = pw.Document();
    final random = Random();

    final pageFormat = _getPageFormat();
    final pages = (pdfData.bingoCount / pdfData.bingosPerPage).ceil();

    for (int i = 0; i < pages; i++) {
      // front side
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(0),
          pageFormat: pageFormat,
          build: (context) {
            return pw.GridView(
              crossAxisCount: cols,
              children: List.generate(pdfData.bingosPerPage, (index) {
                final shuffledEntries = List<String>.from(pdfData.bingoEntries)
                  ..shuffle(random);

                return _buildBingo(
                  context,
                  shuffledEntries,
                );
              }),
            );
          },
        ),
      );

      if (pdfData.backsideText != null || pdfData.backsideImage != null) {
        // back side
        pdf.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(0),
            pageFormat: pageFormat,
            build: (context) {
              return pw.GridView(
                crossAxisCount: cols,
                children: List.generate(
                  pdfData.bingosPerPage,
                  (index) {
                    return pw.Stack(
                      children: [
                        if (pdfData.backsideImage != null)
                          pw.Positioned.fill(
                            child: pw.Image(
                              pdfData.backsideImage!,
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        pw.Center(
                          child: pw.Text(
                            pdfData.backsideText!,
                            style: pw.TextStyle(
                              fontSize: 48 / bingosPerPageSqrt,
                              fontWeight: pw.FontWeight.bold,
                              color: pdfData.backsideTextColor,
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

  PdfPageFormat _getPageFormat() {
    switch (pdfData.bingosPerPage) {
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
  ) {
    final table = pw.Table(
      tableWidth: pw.TableWidth.min,
      border: pw.TableBorder.all(
        color: PdfColors.green800,
        width: 4 / bingosPerPageSqrt,
      ),
      children: List.generate(
        pdfData.gridSize,
        (row) {
          return pw.TableRow(
            children: List.generate(pdfData.gridSize, (col) {
              final index = row * pdfData.gridSize + col;
              return pw.Container(
                width: 80 / bingosPerPageSqrt,
                height: 80 / bingosPerPageSqrt,
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
        if (pdfData.backgroundImage != null)
          pw.Positioned.fill(
            child: pw.Image(
              pdfData.backgroundImage!,
              fit: pw.BoxFit.cover,
            ),
          ),
        pw.Column(
          children: [
            pw.SizedBox(height: 96 / bingosPerPageSqrt),
            pw.Text(
              pdfData.title,
              style: pw.TextStyle(
                fontSize: 48 / bingosPerPageSqrt,
                fontWeight: pw.FontWeight.bold,
                color: pdfData.titleColor,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 24 / bingosPerPageSqrt),
            pw.Text(
              pdfData.description,
              style: pw.TextStyle(
                fontSize: 24 / bingosPerPageSqrt,
                color: pdfData.descriptionColor,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.Expanded(
                child: pw.Align(
              alignment: pw.Alignment.bottomCenter,
              child: table,
            )),
            pw.SizedBox(height: 96 / bingosPerPageSqrt),
          ],
        ),
      ],
    );
  }
}
