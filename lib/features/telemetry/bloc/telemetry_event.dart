part of 'telemetry_bloc.dart';

abstract class TelemetryEvent {}

class LoadTelemetry extends TelemetryEvent {
  final int year;
  final int round;
  final String session;
  final String driver;
  final String metric;

  LoadTelemetry({
    required this.year,
    required this.round,
    required this.session,
    required this.driver,
    required this.metric,
  });
}

class ChangeTelemetryMetric extends TelemetryEvent {
  final String metric;
  ChangeTelemetryMetric({required this.metric});
}
