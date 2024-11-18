part of 'bingo_bloc.dart';

abstract class BingoState {}

class BingoInitial extends BingoState {}

class BingoLoaded extends BingoState {
  final PdfData pdfData;

  BingoLoaded({
    required this.pdfData,
  });
}
