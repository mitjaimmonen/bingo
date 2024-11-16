import 'package:bingo/bloc/pdf_data.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

part 'bingo_event.dart';
part 'bingo_state.dart';

class BingoBloc extends Bloc<BingoEvent, BingoState> {
  BingoBloc() : super(BingoState(pdfData: PdfData.empty())) {
    on<SubmitBingoData>((event, emit) {
      emit(BingoState(
        pdfData: event.pdfData,
      ));
    });
  }
}
