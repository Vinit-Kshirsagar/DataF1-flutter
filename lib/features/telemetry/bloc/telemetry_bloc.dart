import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../data/telemetry_models.dart';
import '../data/telemetry_repository.dart';

part 'telemetry_event.dart';
part 'telemetry_state.dart';

class TelemetryBloc extends Bloc<TelemetryEvent, TelemetryState> {
  final TelemetryRepository _repo;

  TelemetryBloc({TelemetryRepository? repository})
      : _repo = repository ?? TelemetryRepository(),
        super(TelemetryInitial()) {
    on<LoadTelemetry>(_onLoad);
    on<ChangeTelemetryMetric>(_onChangeMetric);
    on<ChangeTelemetryLap>(_onChangeLap);
    on<LoadComparison>(_onLoadComparison);
    on<ChangeComparisonMetric>(_onChangeComparisonMetric);
  }

  Future<void> _onLoad(LoadTelemetry event, Emitter<TelemetryState> emit) async {
    emit(TelemetryLoading());
    try {
      final data = await _repo.getTelemetry(
        year: event.year,
        round: event.round,
        session: event.session,
        driver: event.driver,
        metric: event.metric,
        lapNumber: event.lapNumber,
      );
      if (data.data.isEmpty) {
        emit(TelemetryEmpty());
        return;
      }
      emit(TelemetryLoaded(
        data: data,
        year: event.year,
        round: event.round,
        session: event.session,
        driver: event.driver,
      ));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        emit(TelemetryEmpty());
      } else {
        emit(TelemetryError(message: e.message ?? 'Unable to load data. Tap to retry'));
      }
    } catch (e) {
      emit(TelemetryError(message: 'Unable to load data. Tap to retry'));
    }
  }

  Future<void> _onChangeMetric(
    ChangeTelemetryMetric event,
    Emitter<TelemetryState> emit,
  ) async {
    final current = state;
    if (current is! TelemetryLoaded) return;
    add(LoadTelemetry(
      year: current.year,
      round: current.round,
      session: current.session,
      driver: current.driver,
      metric: event.metric,
      lapNumber: 0, // reset to fastest when changing metric
    ));
  }

  Future<void> _onChangeLap(
    ChangeTelemetryLap event,
    Emitter<TelemetryState> emit,
  ) async {
    final current = state;
    if (current is! TelemetryLoaded) return;
    add(LoadTelemetry(
      year: current.year,
      round: current.round,
      session: current.session,
      driver: current.driver,
      metric: current.data.metric,
      lapNumber: event.lapNumber,
    ));
  }

  Future<void> _onLoadComparison(
    LoadComparison event,
    Emitter<TelemetryState> emit,
  ) async {
    emit(TelemetryLoading());
    try {
      final data = await _repo.getComparison(
        year: event.year,
        round: event.round,
        session: event.session,
        driver1: event.driver1,
        driver2: event.driver2,
        metric: event.metric,
        lapNumber: event.lapNumber,
      );
      emit(ComparisonLoaded(
        data: data,
        year: event.year,
        round: event.round,
        session: event.session,
      ));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        emit(TelemetryEmpty());
      } else {
        emit(TelemetryError(message: e.message ?? 'Unable to load data. Tap to retry'));
      }
    } catch (e) {
      emit(TelemetryError(message: 'Unable to load data. Tap to retry'));
    }
  }

  Future<void> _onChangeComparisonMetric(
    ChangeComparisonMetric event,
    Emitter<TelemetryState> emit,
  ) async {
    final current = state;
    if (current is! ComparisonLoaded) return;
    add(LoadComparison(
      year: current.year,
      round: current.round,
      session: current.session,
      driver1: current.data.driver1.driver,
      driver2: current.data.driver2.driver,
      metric: event.metric,
    ));
  }
}
