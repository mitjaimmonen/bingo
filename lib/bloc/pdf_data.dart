import 'dart:convert';

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
  final PdfColor gridColor;
  final PdfColor gridTextColor;

  final pw.MemoryImage? backgroundImage;
  final pw.MemoryImage? jokerImage;
  final pw.MemoryImage? backsideImage;
  final String? backsideText;
  final PdfColor backsideTextColor;

  final bool fancyTitle;
  final bool fancyBackside;
  final bool middleJoker;

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
    required this.gridColor,
    required this.gridTextColor,
    this.backgroundImage,
    this.backsideImage,
    this.jokerImage,
    this.backsideText,
    this.fancyTitle = true,
    this.fancyBackside = true,
    this.middleJoker = false,
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
      gridColor: const PdfColor.fromInt(0xFF000000),
      gridTextColor: const PdfColor.fromInt(0xFF000000),
      fancyTitle: true,
    );
  }

  String toJson() {
    return jsonEncode({
      'bingoEntries': bingoEntries,
      'gridSize': gridSize,
      'title': title,
      'description': description,
      'bingosPerPage': bingosPerPage,
      'bingoCount': bingoCount,
      'titleColor': titleColor.toInt(),
      'descriptionColor': descriptionColor.toInt(),
      'backsideTextColor': backsideTextColor.toInt(),
      'gridColor': gridColor.toInt(),
      'gridTextColor': gridTextColor.toInt(),
      'fancyTitle': fancyTitle,
      'fancyBackside': fancyBackside,
      'middleJoker': middleJoker,
      'backsideText': backsideText,
    });
  }

  factory PdfData.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return PdfData(
      bingoEntries: List<String>.from(json['bingoEntries']),
      gridSize: json['gridSize'],
      title: json['title'],
      description: json['description'],
      bingosPerPage: json['bingosPerPage'],
      bingoCount: json['bingoCount'],
      titleColor: PdfColor.fromInt(json['titleColor']),
      descriptionColor:
          PdfColor.fromInt(json['descriptionColor']),
      backsideTextColor:
          PdfColor.fromInt(json['backsideTextColor']),
      gridColor: PdfColor.fromInt(json['gridColor']),
      gridTextColor:
          PdfColor.fromInt(json['gridTextColor']),
      fancyTitle: json['fancyTitle'],
      fancyBackside: json['fancyBackside'],
      middleJoker: json['middleJoker'],
      backsideText: json['backsideText'] ?? '',
    );
  }
}
