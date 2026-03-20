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
  }) async {
    final response = await _dio.post(
      '/telemetry/',
      data: {
        'year': year,
        'round': round,
        'session': session,
        'driver': driver,
        'metric': metric,
      },
    );
    return TelemetryData.fromJson(response.data as Map<String, dynamic>);
  }
}
