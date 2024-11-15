import 'dart:html' as html;

import 'package:bingo/bloc/bingo_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;

class CollectDataView extends StatefulWidget {
  const CollectDataView({super.key});

  @override
  State<CollectDataView> createState() => _CollectDataViewState();
}

class _CollectDataViewState extends State<CollectDataView> {
  final _bingoEntriesController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bingoCountController = TextEditingController(text: '1');
  int bingosPerPage = 2;
  int gridSize = 5;
  pw.MemoryImage? backgroundImage;

  final _backsideController = TextEditingController();
  pw.MemoryImage? backsideImage;
  bool hasBacksideText = false;

  void _pickImage({bool backside = false}) async {
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
            if (backside) {
              backsideImage = pw.MemoryImage(reader.result as Uint8List);
            } else {
              backgroundImage = pw.MemoryImage(reader.result as Uint8List);
            }
          });
        });
      }
    });
  }

  void _submitData() {
    final bingoEntries = _bingoEntriesController.text.split('\n');
    final title = _titleController.text;
    final description = _descriptionController.text;
    final bingoCount = int.parse(_bingoCountController.text);
    final backsideText = hasBacksideText ? _backsideController.text : null;

    context.read<BingoBloc>().add(SubmitBingoData(
          bingoEntries: bingoEntries,
          gridSize: gridSize,
          title: title,
          description: description,
          bingosPerPage: bingosPerPage,
          bingoCount: bingoCount,
          backgroundImage: backgroundImage,
          backsideImage: backsideImage,
          backsideText: backsideText,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _bingoEntriesController,
                decoration: const InputDecoration(
                  labelText: 'Bingo Entries (line break separated)',
                ),
                maxLines: 10,
                minLines: 5,
                keyboardType: TextInputType.multiline,
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
                ],
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
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
                controller: _bingoCountController,
                decoration: const InputDecoration(labelText: 'Bingo Count'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
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
              TextField(
                controller: _backsideController,
                onChanged: (value) {
                  setState(() {
                    hasBacksideText = value.isNotEmpty;
                  });
                },
                decoration: const InputDecoration(labelText: 'Backside Text'),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(backside: true),
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
                onPressed: _submitData,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
