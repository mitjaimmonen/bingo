import 'package:bingo/bloc/bingo_bloc.dart';
import 'package:bingo/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

class DataPreviewView extends StatelessWidget {
  const DataPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<BingoBloc, BingoState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: PdfPreview(
                  build: (format) async {
                    final pdfGenerator = PdfGenerator(
                      pdfData: state.pdfData,
                    );
                    final pdf = await pdfGenerator.generatePdf();
                    return pdf.save();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
