import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/dio_client.dart';
import 'auth_models.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? DioClient().dio,
        _storage = storage ?? const FlutterSecureStorage();

  // ── Token storage ──────────────────────────────────────────────────────────

  Future<void> saveTokens(TokenModel tokens) async {
    await Future.wait([
      _storage.write(key: 'access_token', value: tokens.accessToken),
      _storage.write(key: 'refresh_token', value: tokens.refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');

  // ── API calls ──────────────────────────────────────────────────────────────

  Future<UserModel> register(String email, String password) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TokenModel> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final tokens = TokenModel.fromJson(response.data as Map<String, dynamic>);
    await saveTokens(tokens);
    return tokens;
  }

  Future<TokenModel> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final tokens = TokenModel.fromJson(response.data as Map<String, dynamic>);
    await saveTokens(tokens);
    return tokens;
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Session check on app start ─────────────────────────────────────────────

  /// Returns the current user if a valid token exists, otherwise null.
  Future<UserModel?> tryRestoreSession() async {
    final token = await getAccessToken();
    if (token == null) return null;
    try {
      return await getMe();
    } on DioException {
      // Token expired or invalid — clear and return null
      await clearTokens();
      return null;
    }
  }
}
