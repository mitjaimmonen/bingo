import 'dart:math' as math;
import 'dart:math';

import 'package:bingo/bloc/pdf_data.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  final PdfData pdfData;

  final int rows;
  final int cols;
  final double bingosPerPageSqrt;
  static const tableSize = 440.0;

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

    final fancyFontData =
        await rootBundle.load('assets/fonts/Parisienne/Parisienne-Regular.ttf');
    final plainFontData = await rootBundle
        .load('assets/fonts/Host_Grotesk/static/HostGrotesk-Regular.ttf');
    final plainFontItalicData = await rootBundle
        .load('assets/fonts/Host_Grotesk/static/HostGrotesk-LightItalic.ttf');

    final fancyFont = pw.Font.ttf(fancyFontData);
    final plainFont = pw.Font.ttf(plainFontData);
    final plainFontItalic = pw.Font.ttf(plainFontItalicData);

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
                  fancyFont,
                  plainFont,
                  plainFontItalic,
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
                            pdfData.backsideText ?? '',
                            style: pw.TextStyle(
                              font:
                                  pdfData.fancyBackside ? fancyFont : plainFont,
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

  double _approximateFontSize(String content, double preferredFontSize) {
    // Set minimum font size
    final double minFontSize = (40.0 / pdfData.gridSize) / bingosPerPageSqrt;

    // Base calculation on content length
    final int contentLength = content.length;

    // Calculate scaling factor based on content length
    double scalingFactor = 1.0;
    final scaler = pdfData.gridSize == 5 ? 22 : 40;
    scalingFactor = scaler / contentLength;

    // Apply scaling to preferred font size
    double calculatedSize = preferredFontSize * scalingFactor;

    // Ensure font size stays within bounds
    return math.max(minFontSize, math.min(calculatedSize, preferredFontSize));
  }

  pw.Widget _buildBingo(
    pw.Context context,
    List<String> entries,
    pw.Font fancyFont,
    pw.Font plainFont,
    pw.Font plainFontItalic,
  ) {
    final table = pw.Table(
      tableWidth: pw.TableWidth.min,
      border: pw.TableBorder.all(
        color: pdfData.gridColor,
        width: 3 / bingosPerPageSqrt,
      ),
      children: List.generate(
        pdfData.gridSize,
        (row) {
          return pw.TableRow(
            children: List.generate(pdfData.gridSize, (col) {
              final index = row * pdfData.gridSize + col;
              final replaceWithJoker = pdfData.jokerImage != null &&
                  pdfData.middleJoker &&
                  pdfData.gridSize == 5 &&
                  index == 12;
              final containerSize =
                  (tableSize / pdfData.gridSize) / bingosPerPageSqrt;

              return pw.Container(
                width: containerSize,
                height: containerSize,
                constraints: pw.BoxConstraints(
                  minWidth: containerSize,
                  minHeight: containerSize,
                ),
                alignment: pw.Alignment.center,
                child: pw.Stack(
                  children: [
                    pw.Opacity(
                      opacity: 0.75,
                      child: pw.Container(color: const PdfColor(1, 1, 1)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4 / bingosPerPageSqrt),
                      child: pw.Center(
                        child: replaceWithJoker
                            ? pw.FittedBox(
                                fit: pw.BoxFit.contain,
                                child: pw.Image(
                                  pdfData.jokerImage!,
                                  width: 76 / bingosPerPageSqrt,
                                  height: 76 / bingosPerPageSqrt,
                                ),
                              )
                            : pw.Text(
                                index < entries.length ? entries[index] : '',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: plainFont,
                                  fontSize: _approximateFontSize(
                                    index < entries.length
                                        ? entries[index]
                                        : '',
                                    18 / bingosPerPageSqrt,
                                  ),
                                  fontWeight: pw.FontWeight.bold,
                                  color: pdfData.gridTextColor,
                                ),
                              ),
                      ),
                    ),
                  ],
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
            pw.SizedBox(height: 64 / bingosPerPageSqrt),
            pw.ConstrainedBox(
              constraints: pw.BoxConstraints(
                maxWidth: tableSize / bingosPerPageSqrt,
              ),
              child: pw.Padding(
                padding: pw.EdgeInsets.symmetric(
                  vertical: 8 / bingosPerPageSqrt,
                ),
                child: pw.Text(
                  pdfData.title,
                  style: pw.TextStyle(
                    font: pdfData.fancyTitle ? fancyFont : plainFont,
                    fontSize: 48 / bingosPerPageSqrt,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfData.titleColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
            pw.SizedBox(height: 12 / bingosPerPageSqrt),
            pw.ConstrainedBox(
              constraints: pw.BoxConstraints(
                maxWidth: tableSize / bingosPerPageSqrt,
              ),
              child: pw.Padding(
                padding: pw.EdgeInsets.symmetric(
                  vertical: 8 / bingosPerPageSqrt,
                ),
                child: pw.Text(
                  pdfData.description,
                  style: pw.TextStyle(
                    fontItalic: plainFontItalic,
                    fontStyle: pw.FontStyle.italic,
                    fontSize: 24 / bingosPerPageSqrt,
                    color: pdfData.descriptionColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
            pw.Expanded(
                child: pw.Align(
              alignment: pw.Alignment.bottomCenter,
              child: table,
            )),
            pw.SizedBox(height: 80 / bingosPerPageSqrt),
          ],
        ),
      ],
    );
  }
}
