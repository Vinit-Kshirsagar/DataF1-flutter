import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
       baseUrl: 'http://192.168.1.6:8000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(_storage, dio),
      _ErrorInterceptor(),
      LogInterceptor(requestBody: false, responseBody: false),
    ]);
  }
}

// ── Auth Interceptor ────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );
          final newToken = response.data['access_token'] as String;
          await _storage.write(key: 'access_token', value: newToken);

          // Retry original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(opts);
          return handler.resolve(retryResponse);
        } catch (_) {
          // Refresh failed — clear tokens, let AuthBloc handle navigation
          await _storage.deleteAll();
        }
      }
    }
    handler.next(err);
  }
}

// ── Error Interceptor ───────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final serverDetail = err.response?.data?['detail'];

    String message;
    switch (statusCode) {
      case 400:
        message = serverDetail ?? 'Invalid request';
      case 401:
        message = 'Login required';
      case 403:
        message = 'Access denied';
      case 404:
        message = serverDetail ?? 'Content not found';
      case 503:
        message = 'Data not available for selected parameters';
      case 500:
        message = 'Server error. Try again';
      default:
        if (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout) {
          message = 'Unable to load data. Tap to retry';
        } else if (err.type == DioExceptionType.connectionError) {
          message = 'You are offline';
        } else {
          message = serverDetail ?? 'Unable to load data. Tap to retry';
        }
    }

    handler.next(
      err.copyWith(
        message: message,
      ),
    );
  }
}

/// Helper to extract a clean error message from a DioException.
String dioErrorMessage(Object error) {
  if (error is DioException) {
    return error.message ?? 'Unable to load data. Tap to retry';
  }
  return 'Unable to load data. Tap to retry';
}
