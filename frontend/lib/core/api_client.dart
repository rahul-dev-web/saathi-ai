import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

/// Riverpod Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;
  SharedPreferences? _prefs;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _prefs ??= await SharedPreferences.getInstance();

          final token = _prefs!.getString(AppConstants.tokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
        onError: (error, handler) {
          print("API Error: ${error.response?.statusCode}");
          print("Response: ${error.response?.data}");
          handler.next(error);
        },
      ),
    );
  }

  // ==========================================================
  // Generic HTTP Methods
  // ==========================================================

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return await _dio.post(
      path,
      data: data,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String path,
  ) async {
    return await _dio.delete(path);
  }

  // ==========================================================
  // AUTH
  // ==========================================================

  Future<Map<String, dynamic>> signup({
    required String email,
    required String name,
    required String password,
  }) async {
    final response = await post(
      "/auth/signup",
      data: {
        "email": email,
        "name": name,
        "password": password,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await post(
      "/auth/login",
      data: {
        "email": email,
        "password": password,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  // ==========================================================
  // PROFILE
  // ==========================================================

  Future<Map<String, dynamic>> getProfile() async {
    final response = await get("/user/profile");

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
  }) async {
    final response = await put(
      "/user/profile",
      queryParameters: {
        "name": name,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await get("/user/preferences");

    return Map<String, dynamic>.from(response.data);
  }
}