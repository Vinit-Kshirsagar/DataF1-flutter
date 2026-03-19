part of 'telemetry_bloc.dart';

abstract class TelemetryState {}

class TelemetryInitial extends TelemetryState {}
class TelemetryLoading extends TelemetryState {}
class TelemetryLoaded extends TelemetryState {}
class TelemetryError extends TelemetryState {
  final String message;
  TelemetryError(this.message);
}
