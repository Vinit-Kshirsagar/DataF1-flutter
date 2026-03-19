import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/home_models.dart';
import '../data/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repo;

  HomeBloc({HomeRepository? repository})
      : _repo = repository ?? HomeRepository(),
        super(HomeInitial()) {
    on<LoadRaces>(_onLoadRaces);
    on<RaceSelected>(_onRaceSelected);
    on<SessionSelected>(_onSessionSelected);
    on<DriverSelected>(_onDriverSelected);
    on<MetricSelected>(_onMetricSelected);
    on<SelectionStepBack>(_onStepBack);
  }

  Future<void> _onLoadRaces(LoadRaces event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final races = await _repo.getRaces(event.year);
      emit(RacesLoaded(races: races, year: event.year));
    } catch (e) {
      emit(HomeError(message: 'Unable to load data. Tap to retry'));
    }
  }

  Future<void> _onRaceSelected(
    RaceSelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(SessionsLoading(selectedRace: event.race, year: event.year));
    try {
      final sessions = await _repo.getSessions(event.year, event.race.round);
      emit(SessionsLoaded(
        selectedRace: event.race,
        sessions: sessions,
        year: event.year,
      ));
    } catch (e) {
      emit(HomeError(message: 'Unable to load data. Tap to retry'));
    }
  }

  Future<void> _onSessionSelected(
    SessionSelected event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SessionsLoaded) return;

    emit(DriversLoading(
      selectedRace: currentState.selectedRace,
      selectedSession: event.session,
      year: currentState.year,
    ));

    try {
      final drivers = await _repo.getDrivers(
        currentState.year,
        currentState.selectedRace.round,
        event.session.key,
      );
      emit(DriversLoaded(
        selectedRace: currentState.selectedRace,
        selectedSession: event.session,
        drivers: drivers,
        year: currentState.year,
      ));
    } catch (e) {
      emit(HomeError(
        message: 'Unable to load data. Tap to retry',
        previousState: currentState,
      ));
    }
  }

  Future<void> _onDriverSelected(
    DriverSelected event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriversLoaded) return;

    try {
      final metrics = await _repo.getMetrics();
      emit(MetricSelectionReady(
        selectedRace: currentState.selectedRace,
        selectedSession: currentState.selectedSession,
        selectedDriver: event.driver,
        metrics: metrics,
        year: currentState.year,
      ));
    } catch (e) {
      emit(HomeError(
        message: 'Unable to load data. Tap to retry',
        previousState: currentState,
      ));
    }
  }

  void _onMetricSelected(MetricSelected event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! MetricSelectionReady) return;

    emit(SelectionComplete(
      race: currentState.selectedRace,
      session: currentState.selectedSession,
      driver: currentState.selectedDriver,
      metric: event.metric,
      year: currentState.year,
    ));
  }

  void _onStepBack(SelectionStepBack event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is SessionsLoaded || currentState is SessionsLoading) {
      final year = currentState is SessionsLoaded
          ? currentState.year
          : (currentState as SessionsLoading).year;
      add(LoadRaces(year: year));
    } else if (currentState is DriversLoaded) {
      add(RaceSelected(
        race: currentState.selectedRace,
        year: currentState.year,
      ));
    } else if (currentState is MetricSelectionReady) {
      add(SessionSelected(session: currentState.selectedSession));
    }
  }
}
