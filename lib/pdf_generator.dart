import 'dart:math';

import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  final List<String> entries;
  final int gridSize;

  PdfGenerator({required this.entries, this.gridSize = 5});

  Future<pw.Document> generatePdf() async {
    final pdf = pw.Document();
    final random = Random();
    final shuffledEntries = List<String>.from(entries)..shuffle(random);

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.TableHelper.fromTextArray(
            context: context,
            data: List.generate(gridSize, (row) {
              return List.generate(gridSize, (col) {
                final index = row * gridSize + col;
                return index < shuffledEntries.length
                    ? shuffledEntries[index]
                    : '';
              });
            }),
          );
        },
      ),
    );

    return pdf;
  }
}
