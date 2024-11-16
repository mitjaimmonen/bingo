import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfData {
  final List<String> bingoEntries;
  final int gridSize;
  final String title;
  final String description;
  final int bingosPerPage;
  final int bingoCount;
  final PdfColor titleColor;
  final PdfColor descriptionColor;
  final PdfColor backsideTextColor;
  final pw.MemoryImage? backgroundImage;
  final pw.MemoryImage? backsideImage;
  final String? backsideText;

  PdfData({
    required this.bingoEntries,
    required this.gridSize,
    required this.title,
    required this.description,
    required this.bingosPerPage,
    required this.bingoCount,
    required this.titleColor,
    required this.descriptionColor,
    required this.backsideTextColor,
    this.backgroundImage,
    this.backsideImage,
    this.backsideText,
  });

  factory PdfData.empty() {
    return PdfData(
      bingoEntries: [],
      gridSize: 5,
      title: '',
      description: '',
      bingosPerPage: 1,
      bingoCount: 1,
      titleColor: const PdfColor.fromInt(0xFF000000),
      descriptionColor: const PdfColor.fromInt(0xFF000000),
      backsideTextColor: const PdfColor.fromInt(0xFF000000),
    );
  }
}
