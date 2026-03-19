part of 'home_bloc.dart';

abstract class HomeEvent {}

class LoadRaces extends HomeEvent {
  final int year;
  LoadRaces({required this.year});
}

class RaceSelected extends HomeEvent {
  final RaceModel race;
  final int year;
  RaceSelected({required this.race, required this.year});
}

class SessionSelected extends HomeEvent {
  final SessionModel session;
  SessionSelected({required this.session});
}

class DriverSelected extends HomeEvent {
  final DriverModel driver;
  DriverSelected({required this.driver});
}

class MetricSelected extends HomeEvent {
  final MetricModel metric;
  MetricSelected({required this.metric});
}

class SelectionStepBack extends HomeEvent {}
