class DataPoint {
  final double x;
  final double y;

  const DataPoint({required this.x, required this.y});

  factory DataPoint.fromJson(Map<String, dynamic> json) => DataPoint(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}

class LapInfo {
  final int lapNumber;
  final double? lapTime; // seconds
  final bool isFastest;

  const LapInfo({
    required this.lapNumber,
    this.lapTime,
    this.isFastest = false,
  });

  factory LapInfo.fromJson(Map<String, dynamic> json) => LapInfo(
        lapNumber: json['lap_number'] as int,
        lapTime: json['lap_time'] != null
            ? (json['lap_time'] as num).toDouble()
            : null,
        isFastest: json['is_fastest'] as bool? ?? false,
      );

  String get formattedTime {
    if (lapTime == null) return '--:--.---';
    final mins = (lapTime! ~/ 60).toInt();
    final secs = lapTime! % 60;
    if (mins > 0) return '$mins:${secs.toStringAsFixed(3).padLeft(6, '0')}';
    return secs.toStringAsFixed(3);
  }
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
  final int selectedLap;
  final List<LapInfo> laps;
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
    this.selectedLap = 0,
    this.laps = const [],
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
        selectedLap: json['selected_lap'] as int? ?? 0,
        laps: json['laps'] != null
            ? (json['laps'] as List)
                .map((l) => LapInfo.fromJson(l as Map<String, dynamic>))
                .toList()
            : [],
        summary: json['summary'] as String,
        partial: json['partial'] as bool? ?? false,
      );
}

// ── Comparison models ─────────────────────────────────────────────────────────

class ComparisonDriver {
  final String driver;
  final String driverFullName;
  final String team;
  final List<DataPoint> data;
  final double? fastestLap;
  final int selectedLap;

  const ComparisonDriver({
    required this.driver,
    required this.driverFullName,
    required this.team,
    required this.data,
    this.fastestLap,
    this.selectedLap = 0,
  });

  factory ComparisonDriver.fromJson(Map<String, dynamic> json) =>
      ComparisonDriver(
        driver: json['driver'] as String,
        driverFullName: json['driver_full_name'] as String,
        team: json['team'] as String,
        data: (json['data'] as List)
            .map((d) => DataPoint.fromJson(d as Map<String, dynamic>))
            .toList(),
        fastestLap: json['fastest_lap'] != null
            ? (json['fastest_lap'] as num).toDouble()
            : null,
        selectedLap: json['selected_lap'] as int? ?? 0,
      );
}

class ComparisonData {
  final int year;
  final int round;
  final String session;
  final String metric;
  final String metricLabel;
  final String metricUnit;
  final ComparisonDriver driver1;
  final ComparisonDriver driver2;
  final String summary;

  const ComparisonData({
    required this.year,
    required this.round,
    required this.session,
    required this.metric,
    required this.metricLabel,
    required this.metricUnit,
    required this.driver1,
    required this.driver2,
    required this.summary,
  });

  factory ComparisonData.fromJson(Map<String, dynamic> json) => ComparisonData(
        year: json['year'] as int,
        round: json['round'] as int,
        session: json['session'] as String,
        metric: json['metric'] as String,
        metricLabel: json['metric_label'] as String,
        metricUnit: json['metric_unit'] as String,
        driver1: ComparisonDriver.fromJson(
            json['driver1'] as Map<String, dynamic>),
        driver2: ComparisonDriver.fromJson(
            json['driver2'] as Map<String, dynamic>),
        summary: json['summary'] as String,
      );
}
