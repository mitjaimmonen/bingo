import 'dart:html' as html;

import 'package:bingo/bloc/bingo_bloc.dart';
import 'package:bingo/bloc/pdf_data.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CollectDataView extends StatefulWidget {
  final Function openPreview;

  const CollectDataView({
    super.key,
    required this.openPreview,
  });

  @override
  State<CollectDataView> createState() => _CollectDataViewState();
}

class _CollectDataViewState extends State<CollectDataView> {
  int bingosPerPage = 2;
  int gridSize = 5;
  pw.MemoryImage? backgroundImage;
  bool fancyTitle = true;

  pw.MemoryImage? backsideImage;
  bool hasBacksideText = false;
  bool fancyBackside = true;

  pw.MemoryImage? jokerImage;
  bool middleJoker = true;

  Color titleColor = const Color(0xFF800000);
  Color descriptionColor = const Color(0xFF008000);
  Color backsideTextColor = const Color(0xFFD29292);
  Color gridColor = const Color(0xFF1C8000);
  Color gridTextColor = const Color(0xFF1C8000);

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BingoBloc>();

    if (bloc.state is BingoLoaded) {
      bloc.bingoEntriesController.text =
          (bloc.state as BingoLoaded).pdfData.bingoEntries.join('\n');
      bloc.titleController.text = (bloc.state as BingoLoaded).pdfData.title;
      bloc.descriptionController.text =
          (bloc.state as BingoLoaded).pdfData.description;
      bloc.bingoCountController.text =
          (bloc.state as BingoLoaded).pdfData.bingoCount.toString();
      bloc.backsideController.text =
          (bloc.state as BingoLoaded).pdfData.backsideText ?? '';
      gridSize = (bloc.state as BingoLoaded).pdfData.gridSize;
      bingosPerPage = (bloc.state as BingoLoaded).pdfData.bingosPerPage;
      titleColor =
          Color((bloc.state as BingoLoaded).pdfData.titleColor.toInt());
      descriptionColor =
          Color((bloc.state as BingoLoaded).pdfData.descriptionColor.toInt());
      backsideTextColor =
          Color((bloc.state as BingoLoaded).pdfData.backsideTextColor.toInt());
      gridColor = Color((bloc.state as BingoLoaded).pdfData.gridColor.toInt());
      gridTextColor =
          Color((bloc.state as BingoLoaded).pdfData.gridTextColor.toInt());
    }
  }

  void _pickColor(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.wheel: true,
              },
              onColorChanged: onColorChanged,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _pickImage(Function(pw.MemoryImage?) onImagePicked) async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          setState(() {
            onImagePicked(pw.MemoryImage(reader.result as Uint8List));
          });
        });
      }
    });
  }

  void _submitData(BingoBloc bloc) {
    final bingoEntries = bloc.bingoEntriesController.text.split('\n');
    final title = bloc.titleController.text;
    final description = bloc.descriptionController.text;
    final bingoCount = int.parse(bloc.bingoCountController.text);
    final backsideText = hasBacksideText ? bloc.backsideController.text : null;

    context.read<BingoBloc>().add(
          SubmitBingoData(
            pdfData: PdfData(
              bingoEntries: bingoEntries,
              gridSize: gridSize,
              title: title,
              description: description,
              bingosPerPage: bingosPerPage,
              bingoCount: bingoCount,
              backgroundImage: backgroundImage,
              backsideImage: backsideImage,
              jokerImage: jokerImage,
              backsideText: backsideText,
              fancyTitle: fancyTitle,
              titleColor: PdfColor.fromInt(titleColor.value),
              descriptionColor: PdfColor.fromInt(descriptionColor.value),
              backsideTextColor: PdfColor.fromInt(backsideTextColor.value),
              gridColor: PdfColor.fromInt(gridColor.value),
              gridTextColor: PdfColor.fromInt(gridTextColor.value),
              fancyBackside: fancyBackside,
              middleJoker: middleJoker,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BingoBloc>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: bloc.bingoEntriesController,
                    decoration: const InputDecoration(
                      labelText: 'Bingo Entries (line break separated)',
                    ),
                    maxLines: 10,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gridTextColor,
                    foregroundColor: gridTextColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () => _pickColor(gridTextColor, (color) {
                    setState(() {
                      gridTextColor = color;
                    });
                  }),
                  child: const Text('Grid Text Color'),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Grid Size: ',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                DropdownButton<int>(
                  value: gridSize,
                  onChanged: (value) {
                    setState(() {
                      gridSize = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 4, child: Text('4x4')),
                    DropdownMenuItem(value: 5, child: Text('5x5')),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gridColor,
                    foregroundColor: gridColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () => _pickColor(gridColor, (color) {
                    setState(() {
                      gridColor = color;
                    });
                  }),
                  child: const Text('Grid Color'),
                ),
              ],
            ),
            if (gridSize == 5)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage((image) {
                      setState(() {
                        jokerImage = image;
                      });
                    }),
                    child: const Text('Pick Joker Image'),
                  ),
                  if (jokerImage != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          jokerImage = null;
                        });
                      },
                      child: const Text('Remove Joker Image'),
                    ),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 2,
                    controller: bloc.titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const Text('Fancy: '),
                Switch(
                  value: fancyTitle,
                  onChanged: (value) {
                    setState(() {
                      fancyTitle = value;
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: titleColor,
                    foregroundColor: titleColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () => _pickColor(titleColor, (color) {
                    setState(() {
                      titleColor = color;
                    });
                  }),
                  child: const Text('Title Color'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 2,
                    controller: bloc.descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: descriptionColor,
                    foregroundColor: descriptionColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () => _pickColor(descriptionColor, (color) {
                    setState(() {
                      descriptionColor = color;
                    });
                  }),
                  child: const Text('Description Color'),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Bingos per Page: ',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                DropdownButton<int>(
                  value: bingosPerPage,
                  onChanged: (value) {
                    setState(() {
                      bingosPerPage = value ?? 1;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1')),
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 4, child: Text('4')),
                    DropdownMenuItem(value: 8, child: Text('8')),
                    DropdownMenuItem(value: 16, child: Text('16')),
                  ],
                ),
              ],
            ),
            TextField(
              controller: bloc.bingoCountController,
              decoration: const InputDecoration(labelText: 'Bingo Count'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage((image) {
                    setState(() {
                      backgroundImage = image;
                    });
                  }),
                  child: const Text('Pick Background Image'),
                ),
                if (backgroundImage != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        backgroundImage = null;
                      });
                    },
                    child: const Text('Remove Background Image'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: bloc.backsideController,
                    onChanged: (value) {
                      setState(() {
                        hasBacksideText = value.isNotEmpty;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Backside Text'),
                  ),
                ),
                const Text('Fancy: '),
                Switch(
                  value: fancyBackside,
                  onChanged: (value) {
                    setState(() {
                      fancyBackside = value;
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backsideTextColor,
                    foregroundColor: backsideTextColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () => _pickColor(backsideTextColor, (color) {
                    setState(() {
                      backsideTextColor = color;
                    });
                  }),
                  child: const Text('Back Text Color'),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage((image) {
                    setState(() {
                      backsideImage = image;
                    });
                  }),
                  child: const Text('Pick Backside Image'),
                ),
                if (backsideImage != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        backsideImage = null;
                      });
                    },
                    child: const Text('Remove Backside Image'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (backsideImage != null || hasBacksideText)
              Text(
                'Backside is enabled!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _submitData(bloc);
                widget.openPreview();
              },
              child: const Text('Save & Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
