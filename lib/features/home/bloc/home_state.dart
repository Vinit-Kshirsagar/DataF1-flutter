part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class RacesLoaded extends HomeState {
  final List<RaceModel> races;
  final int year;
  RacesLoaded({required this.races, required this.year});
}

class SessionsLoading extends HomeState {
  final RaceModel selectedRace;
  final int year;
  SessionsLoading({required this.selectedRace, required this.year});
}

class SessionsLoaded extends HomeState {
  final RaceModel selectedRace;
  final List<SessionModel> sessions;
  final int year;
  SessionsLoaded({
    required this.selectedRace,
    required this.sessions,
    required this.year,
  });
}

class DriversLoading extends HomeState {
  final RaceModel selectedRace;
  final SessionModel selectedSession;
  final int year;
  DriversLoading({
    required this.selectedRace,
    required this.selectedSession,
    required this.year,
  });
}

class DriversLoaded extends HomeState {
  final RaceModel selectedRace;
  final SessionModel selectedSession;
  final List<DriverModel> drivers;
  final int year;
  DriversLoaded({
    required this.selectedRace,
    required this.selectedSession,
    required this.drivers,
    required this.year,
  });
}

class MetricSelectionReady extends HomeState {
  final RaceModel selectedRace;
  final SessionModel selectedSession;
  final DriverModel selectedDriver;
  final List<MetricModel> metrics;
  final int year;
  MetricSelectionReady({
    required this.selectedRace,
    required this.selectedSession,
    required this.selectedDriver,
    required this.metrics,
    required this.year,
  });
}

class SelectionComplete extends HomeState {
  final RaceModel race;
  final SessionModel session;
  final DriverModel driver;
  final MetricModel metric;
  final int year;
  SelectionComplete({
    required this.race,
    required this.session,
    required this.driver,
    required this.metric,
    required this.year,
  });
}

class HomeError extends HomeState {
  final String message;
  final HomeState? previousState;
  HomeError({required this.message, this.previousState});
}
