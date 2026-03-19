import 'package:flutter_bloc/flutter_bloc.dart';

part 'predictions_event.dart';
part 'predictions_state.dart';

class PredictionsBloc extends Bloc<PredictionsEvent, PredictionsState> {
  PredictionsBloc() : super(PredictionsInitial()) {
    on<LoadPredictions>(_onLoad);
  }

  Future<void> _onLoad(LoadPredictions event, Emitter<PredictionsState> emit) async {
    emit(PredictionsLoading());
    emit(PredictionsLoaded());
  }
}
