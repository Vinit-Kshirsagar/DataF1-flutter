part of 'telemetry_bloc.dart';

abstract class TelemetryState {}

class TelemetryInitial extends TelemetryState {}

class TelemetryLoading extends TelemetryState {}

class TelemetryLoaded extends TelemetryState {
  final TelemetryData data;
  // Keep track of original params so metric can be swapped
  final int year;
  final int round;
  final String session;
  final String driver;

  TelemetryLoaded({
    required this.data,
    required this.year,
    required this.round,
    required this.session,
    required this.driver,
  });
}

class TelemetryEmpty extends TelemetryState {
  final String message;
  TelemetryEmpty({this.message = 'Data not available for selected parameters'});
}

class TelemetryError extends TelemetryState {
  final String message;
  TelemetryError({required this.message});
}
