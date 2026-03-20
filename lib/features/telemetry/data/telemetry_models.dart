class DataPoint {
  final double x;
  final double y;

  const DataPoint({required this.x, required this.y});

  factory DataPoint.fromJson(Map<String, dynamic> json) => DataPoint(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}

class TelemetryData {
  final int year;
  final int round;
  final String session;
  final String driver;
  final String driverFullName;
  final String team;
  final String metric;
  final String metricLabel;
  final String metricUnit;
  final List<DataPoint> data;
  final int totalLaps;
  final double? fastestLap;
  final String summary;
  final bool partial;

  const TelemetryData({
    required this.year,
    required this.round,
    required this.session,
    required this.driver,
    required this.driverFullName,
    required this.team,
    required this.metric,
    required this.metricLabel,
    required this.metricUnit,
    required this.data,
    required this.totalLaps,
    this.fastestLap,
    required this.summary,
    this.partial = false,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) => TelemetryData(
        year: json['year'] as int,
        round: json['round'] as int,
        session: json['session'] as String,
        driver: json['driver'] as String,
        driverFullName: json['driver_full_name'] as String,
        team: json['team'] as String,
        metric: json['metric'] as String,
        metricLabel: json['metric_label'] as String,
        metricUnit: json['metric_unit'] as String,
        data: (json['data'] as List)
            .map((d) => DataPoint.fromJson(d as Map<String, dynamic>))
            .toList(),
        totalLaps: json['total_laps'] as int,
        fastestLap: json['fastest_lap'] != null
            ? (json['fastest_lap'] as num).toDouble()
            : null,
        summary: json['summary'] as String,
        partial: json['partial'] as bool? ?? false,
      );
}
