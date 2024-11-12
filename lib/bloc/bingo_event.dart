part of 'bingo_bloc.dart';

@immutable
sealed class BingoEvent {}

class SubmitBingoData extends BingoEvent {
  final List<String> bingoEntries;
  final int gridSize;
  final String title;
  final String description;
  final int bingosPerPage;
  final int bingoCount;

  SubmitBingoData({
    required this.bingoEntries,
    required this.gridSize,
    required this.title,
    required this.description,
    required this.bingosPerPage,
    required this.bingoCount,
  });
}
