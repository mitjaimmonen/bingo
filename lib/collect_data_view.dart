import 'package:bingo/bloc/bingo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollectDataView extends StatefulWidget {
  const CollectDataView({super.key});

  @override
  State<CollectDataView> createState() => _CollectDataViewState();
}

class _CollectDataViewState extends State<CollectDataView> {
  final TextEditingController _bingoEntriesController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bingosPerPageController =
      TextEditingController();
  final TextEditingController _bingoCountController = TextEditingController();
  int _gridSize = 5;

  void _submitData() {
    final bingoEntries = _bingoEntriesController.text.split('\n');
    final title = _titleController.text;
    final description = _descriptionController.text;
    final bingosPerPage = int.parse(_bingosPerPageController.text);
    final bingoCount = int.parse(_bingoCountController.text);

    context.read<BingoBloc>().add(SubmitBingoData(
          bingoEntries: bingoEntries,
          gridSize: _gridSize,
          title: title,
          description: description,
          bingosPerPage: bingosPerPage,
          bingoCount: bingoCount,
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
              DropdownButton<int>(
                value: _gridSize,
                onChanged: (value) {
                  setState(() {
                    _gridSize = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 4, child: Text('4x4')),
                  DropdownMenuItem(value: 5, child: Text('5x5')),
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
              TextField(
                controller: _bingosPerPageController,
                decoration: const InputDecoration(
                    labelText: 'Bingos Per Page (power of two)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _bingoCountController,
                decoration: const InputDecoration(labelText: 'Bingo Count'),
                keyboardType: TextInputType.number,
              ),
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
