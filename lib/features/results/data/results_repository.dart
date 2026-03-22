import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'results_models.dart';

class ResultsRepository {
  final Dio _dio;

  ResultsRepository({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<RaceResultsData> getResults({
    required int year,
    required int round,
    String session = 'R',
  }) async {
    final response = await _dio.get(
      '/races/$year/$round/results',
      queryParameters: {'session': session},
    );
    return RaceResultsData.fromJson(response.data as Map<String, dynamic>);
  }
}
