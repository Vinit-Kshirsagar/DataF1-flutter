import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'home_models.dart';

class HomeRepository {
  final Dio _dio;

  HomeRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<List<RaceModel>> getRaces(int year) async {
    final response = await _dio.get('/races/$year');
    final List races = response.data['races'] as List;
    return races
        .map((r) => RaceModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<SessionModel>> getSessions(int year, int round) async {
    final response = await _dio.get('/races/$year/$round/sessions');
    final List sessions = response.data['sessions'] as List;
    return sessions
        .map((s) => SessionModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<DriverModel>> getDrivers(
    int year,
    int round,
    String sessionKey,
  ) async {
    final response =
        await _dio.get('/races/$year/$round/sessions/$sessionKey/drivers');
    final List drivers = response.data['drivers'] as List;
    return drivers
        .map((d) => DriverModel.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<List<MetricModel>> getMetrics() async {
    final response = await _dio.get('/races/metrics');
    final List metrics = response.data['metrics'] as List;
    return metrics
        .map((m) => MetricModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }
}
