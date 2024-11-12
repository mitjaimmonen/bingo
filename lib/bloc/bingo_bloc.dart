import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bingo_event.dart';
part 'bingo_state.dart';

class BingoBloc extends Bloc<BingoEvent, BingoState> {
  BingoBloc()
      : super(BingoState(
          bingoEntries: [],
          gridSize: 5,
          title: '',
          description: '',
          bingosPerPage: 1,
          bingoCount: 1,
        )) {
    on<SubmitBingoData>((event, emit) {
      emit(BingoState(
        bingoEntries: event.bingoEntries,
        gridSize: event.gridSize,
        title: event.title,
        description: event.description,
        bingosPerPage: event.bingosPerPage,
        bingoCount: event.bingoCount,
      ));
    });
  }
}
