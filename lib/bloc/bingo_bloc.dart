import 'package:bingo/bloc/pdf_data.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'bingo_event.dart';
part 'bingo_state.dart';

class BingoBloc extends Bloc<BingoEvent, BingoState> {
  final bingoEntriesController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final bingoCountController = TextEditingController(text: '1');

  BingoBloc() : super(BingoState(pdfData: PdfData.empty())) {
    on<SubmitBingoData>((event, emit) {
      emit(BingoState(
        pdfData: event.pdfData,
      ));
    });
  }
}
