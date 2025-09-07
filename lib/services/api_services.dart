import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {

  static Future<void> wakeUpServer() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.wakeUpEndpoint}');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        print("✅ Server is awake: ${jsonDecode(response.body)}");
      } else {
        print("⚠️ Wake-up request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Failed to wake up server: $e");
    }
  }
}


class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30), 
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'accept': 'application/json',
      },
    ),
  );

  static Future<void> initializeInterceptors() async {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final useToken = options.extra['useToken'] ?? true;


          return handler.next(options);
        },
      ),
    );
  }

  static Dio get dio {
    if (_dio.interceptors.isEmpty) {
      initializeInterceptors();
    }
    return _dio;
  }
}