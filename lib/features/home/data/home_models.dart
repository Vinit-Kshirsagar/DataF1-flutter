class RaceModel {
  final int round;
  final String name;
  final String country;
  final String circuit;
  final String date;

  const RaceModel({
    required this.round,
    required this.name,
    required this.country,
    required this.circuit,
    required this.date,
  });

  factory RaceModel.fromJson(Map<String, dynamic> json) => RaceModel(
        round: json['round'] as int,
        name: json['name'] as String,
        country: json['country'] as String,
        circuit: json['circuit'] as String,
        date: json['date'] as String,
      );
}

class SessionModel {
  final String key;
  final String name;

  const SessionModel({required this.key, required this.name});

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        key: json['key'] as String,
        name: json['name'] as String,
      );
}

class DriverModel {
  final String code;
  final String fullName;
  final String team;
  final String? number;

  const DriverModel({
    required this.code,
    required this.fullName,
    required this.team,
    this.number,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        code: json['code'] as String,
        fullName: json['full_name'] as String,
        team: json['team'] as String,
        number: json['number'] as String?,
      );
}

class MetricModel {
  final String key;
  final String label;
  final String unit;

  const MetricModel({
    required this.key,
    required this.label,
    required this.unit,
  });

  factory MetricModel.fromJson(Map<String, dynamic> json) => MetricModel(
        key: json['key'] as String,
        label: json['label'] as String,
        unit: json['unit'] as String,
      );
}
