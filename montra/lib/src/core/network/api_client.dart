import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  // Using 10.0.2.2 for Android emulator to hit localhost:8000
  static const String _baseUrl = 'http://10.0.2.2:8000';
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }

  Dio get client => _dio;
}
