import 'package:aces_uniben/config/api_config.dart';
import 'package:aces_uniben/services/api_services.dart';
import 'package:aces_uniben/services/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class AuthService {
  final Dio _dio = DioClient.dio;
  final Logger _logger = Logger();

  Future<Response> login(String email, String password) async {
    try {
      
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      _logger.i("Login successful");
      _logger.d("Response: ${response.data}");
      
      return response;
    } on DioException catch (dioError) {
      _logger.e("Login failed: ${dioError.message}");
      if (dioError.response != null) {
        _logger.e("Status: ${dioError.response?.statusCode}, Data: ${dioError.response?.data}");
      }
      rethrow;
    } catch (e) {
      _logger.e("Unexpected login error: $e");
      rethrow;
    }
  }


  
  Future<Response> forgotPassword(String email) async {
    try {
      
      final response = await _dio.post(
        ApiConfig.forgottenPasswordEndpoint,
        data: {
          'email': email,
        },
      );

      
      return response;
    } 
    catch (e) {
      rethrow;
    }
  }

  
  Future<Response> verifyCode(String email, String code) async {
    try {
      
      final response = await _dio.post(
        ApiConfig.verifyCodeEndpoint,
        data: {
          'email': email,
          'code': code
        },
      );

      
      return response;
    } 
    catch (e) {
      rethrow;
    }
  }

   Future<Response> resetPassword(String email, String code, String n) async {
    try {
      
      final response = await _dio.post(
        ApiConfig.resetPasswordEndpoint,
        data: {
          'email': email,
          'code': code,
          'newPassword': n
        },
      );

      
      return response;
    } 
    catch (e) {
      rethrow;
    }
  }




  Future<Response> updateProfile({
  required String fullName,
  required String phoneNumber,
  required String matriculationNumber,
  required String universityEmail,
  required String level,
}) async {
  try {
    final token = await SecureStorage.getToken();
    final response = await _dio.put(
      ApiConfig.profileEndpoint,
      data: {
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "matriculationNumber": matriculationNumber,
        "universityEmail": universityEmail,
        "level": level,
      },
      options: Options(
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    _logger.i("Profile update successful");
    _logger.d("Response: ${response.data}");
    
    return response;
  } on DioException catch (dioError) {
    _logger.e("Profile update failed: ${dioError.message}");
    if (dioError.response != null) {
      _logger.e("Status: ${dioError.response?.statusCode}, Data: ${dioError.response?.data}");
    }
    rethrow;
  } catch (e) {
    _logger.e("Unexpected profile update error: $e");
    rethrow;
  }
}


}