import 'package:flutter_bloc/flutter_bloc.dart';

part 'telemetry_event.dart';
part 'telemetry_state.dart';

class TelemetryBloc extends Bloc<TelemetryEvent, TelemetryState> {
  TelemetryBloc() : super(TelemetryInitial()) {
    on<LoadTelemetry>(_onLoad);
  }

  Future<void> _onLoad(LoadTelemetry event, Emitter<TelemetryState> emit) async {
    emit(TelemetryLoading());
    emit(TelemetryLoaded());
  }
}
