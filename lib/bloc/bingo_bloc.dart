import 'package:bingo/bloc/pdf_data.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

part 'bingo_event.dart';
part 'bingo_state.dart';

class BingoBloc extends Bloc<BingoEvent, BingoState> {
  final bingoEntriesController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final bingoCountController = TextEditingController(text: '1');
  final backsideController = TextEditingController();

  BingoBloc() : super(BingoInitial()) {
    on<SubmitBingoData>((event, emit) async {
      await _savePdfData(event.pdfData);

      emit(BingoLoaded(
        pdfData: event.pdfData,
      ));
    });

    on<SaveBingoData>((event, emit) async {
      await _savePdfData(event.pdfData);
    });

    on<LoadBingoData>((event, emit) async {
      final pdfData = await _loadPdfData();
      emit(BingoLoaded(pdfData: pdfData));
    });
  }

  Future<void> _savePdfData(PdfData pdfData) async {
    try {
      localStorage.setItem('pdfData', pdfData.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save PDF data: $e');
      }
    }
  }

  Future<PdfData> _loadPdfData() async {
    try {
      final jsonString = localStorage.getItem('pdfData');
      if (jsonString != null) {
        return PdfData.fromJson(jsonString);
      } else {
        return PdfData.empty();
      }
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('Failed to load PDF data: $e\n$stacktrace');
      }
      return PdfData.empty();
    }
  }
}
