part of 'telemetry_bloc.dart';

abstract class TelemetryEvent {}

class LoadTelemetry extends TelemetryEvent {
  final int year;
  final int round;
  final String session;
  final String driver;
  final String metric;
  final int lapNumber;

  LoadTelemetry({
    required this.year,
    required this.round,
    required this.session,
    required this.driver,
    required this.metric,
    this.lapNumber = 0,
  });
}

class ChangeTelemetryMetric extends TelemetryEvent {
  final String metric;
  ChangeTelemetryMetric({required this.metric});
}

class ChangeTelemetryLap extends TelemetryEvent {
  final int lapNumber;
  ChangeTelemetryLap({required this.lapNumber});
}

class LoadComparison extends TelemetryEvent {
  final int year;
  final int round;
  final String session;
  final String driver1;
  final String driver2;
  final String metric;
  final int lapNumber;

  LoadComparison({
    required this.year,
    required this.round,
    required this.session,
    required this.driver1,
    required this.driver2,
    required this.metric,
    this.lapNumber = 0,
  });
}

class ChangeComparisonMetric extends TelemetryEvent {
  final String metric;
  ChangeComparisonMetric({required this.metric});
}
