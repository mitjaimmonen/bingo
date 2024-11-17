import 'package:bingo/bloc/bingo_bloc.dart';
import 'package:bingo/collect_data_view.dart';
import 'package:bingo/data_preview_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => BingoBloc(),
        child: const MyHomePage(title: 'Bingo PDF Generator'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1000) {
                return TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Collect Data'),
                    Tab(text: 'Preview Data'),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1000) {
            return TabBarView(
              controller: _tabController,
              children: [
                CollectDataView(
                  openPreview: () {
                    _tabController.index = 1;
                  },
                ),
                const DataPreviewView(),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: CollectDataView(
                    openPreview: () {
                      _tabController.index = 1;
                    },
                  ),
                ),
                const Expanded(child: DataPreviewView()),
              ],
            );
          }
        },
      ),
    );
  }
}
