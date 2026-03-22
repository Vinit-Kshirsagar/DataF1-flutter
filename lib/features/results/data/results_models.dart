class DriverResult {
  final int? position;
  final String driverCode;
  final String driverFullName;
  final String team;
  final int? gridPosition;
  final double points;
  final String status;
  final bool fastestLap;
  final String? gapToLeader;

  const DriverResult({
    this.position,
    required this.driverCode,
    required this.driverFullName,
    required this.team,
    this.gridPosition,
    this.points = 0.0,
    required this.status,
    this.fastestLap = false,
    this.gapToLeader,
  });

  bool get isDNF => status == 'DNF' || status == 'DNS' || status == 'DSQ';

  factory DriverResult.fromJson(Map<String, dynamic> json) => DriverResult(
        position: json['position'] as int?,
        driverCode: json['driver_code'] as String,
        driverFullName: json['driver_full_name'] as String,
        team: json['team'] as String,
        gridPosition: json['grid_position'] as int?,
        points: (json['points'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] as String,
        fastestLap: json['fastest_lap'] as bool? ?? false,
        gapToLeader: json['gap_to_leader'] as String?,
      );
}

class RaceResultsData {
  final int year;
  final int round;
  final String raceName;
  final String session;
  final String circuit;
  final String date;
  final List<DriverResult> results;
  final int totalDrivers;

  const RaceResultsData({
    required this.year,
    required this.round,
    required this.raceName,
    required this.session,
    required this.circuit,
    required this.date,
    required this.results,
    required this.totalDrivers,
  });

  factory RaceResultsData.fromJson(Map<String, dynamic> json) => RaceResultsData(
        year: json['year'] as int,
        round: json['round'] as int,
        raceName: json['race_name'] as String,
        session: json['session'] as String,
        circuit: json['circuit'] as String? ?? '',
        date: json['date'] as String? ?? '',
        results: (json['results'] as List)
            .map((r) => DriverResult.fromJson(r as Map<String, dynamic>))
            .toList(),
        totalDrivers: json['total_drivers'] as int,
      );
}
