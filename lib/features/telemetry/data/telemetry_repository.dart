import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'telemetry_models.dart';

class TelemetryRepository {
  final Dio _dio;

  TelemetryRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<TelemetryData> getTelemetry({
    required int year,
    required int round,
    required String session,
    required String driver,
    required String metric,
    int lapNumber = 0,
  }) async {
    final response = await _dio.post('/telemetry/', data: {
      'year': year,
      'round': round,
      'session': session,
      'driver': driver,
      'metric': metric,
      'lap_number': lapNumber,
    });
    return TelemetryData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ComparisonData> getComparison({
    required int year,
    required int round,
    required String session,
    required String driver1,
    required String driver2,
    required String metric,
    int lapNumber = 0,
  }) async {
    final response = await _dio.post('/telemetry/compare', data: {
      'year': year,
      'round': round,
      'session': session,
      'driver1': driver1,
      'driver2': driver2,
      'metric': metric,
      'lap_number': lapNumber,
    });
    return ComparisonData.fromJson(response.data as Map<String, dynamic>);
  }
}
