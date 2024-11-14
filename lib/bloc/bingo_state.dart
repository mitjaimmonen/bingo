part of 'bingo_bloc.dart';

class BingoState {
  final List<String> bingoEntries;
  final int gridSize;
  final String title;
  final String description;
  final int bingosPerPage;
  final int bingoCount;
  final pw.MemoryImage? backgroundImage;

  BingoState({
    required this.bingoEntries,
    required this.gridSize,
    required this.title,
    required this.description,
    required this.bingosPerPage,
    required this.bingoCount,
    this.backgroundImage,
  });
}
