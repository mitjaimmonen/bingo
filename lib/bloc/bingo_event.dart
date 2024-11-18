part of 'bingo_bloc.dart';

@immutable
sealed class BingoEvent {}

class SubmitBingoData extends BingoEvent {
  final PdfData pdfData;

  SubmitBingoData({
    required this.pdfData,
  });
}

class SaveBingoData extends BingoEvent {
  final PdfData pdfData;

  SaveBingoData({
    required this.pdfData,
  });
}

class LoadBingoData extends BingoEvent {
  LoadBingoData();
}
