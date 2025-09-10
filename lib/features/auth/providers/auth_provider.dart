import 'dart:convert';
import 'package:aces_uniben/features/auth/models/student_model.dart';
import 'package:aces_uniben/features/auth/providers/auth_service.dart';
import 'package:aces_uniben/services/db_helper.dart';
import 'package:aces_uniben/services/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AuthProvider with ChangeNotifier {
  AcesStudent? _user;

  AcesStudent? get user => _user;
  bool get isAuthenticated => _user != null;
  String? _error;

  

  final AuthService _authService = AuthService();
  var logger = Logger();

  Future<void> loadUser() async {
    _user = await DBHelper.getProfile();
    final token = await DBHelper.getToken();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {

    try {
      final response = await _authService.login(email, password);

      if (response.statusCode == 200) {
        final data = response.data?['user'];

        final user = AcesStudent(
          id: data['id'],
          name: data['name'],
          email: data['email'],
          matNo: data['matNo'],
          uniEmail: data['uniEmail'],
          level: data['level'],
        );

        _user = user;
        await DBHelper.saveProfile(user, token: response.data?['token']);

        await SecureStorage.setToken(response.data?['token']);
        await SecureStorage.setUsername(user.name);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String matriculationNumber,
    required String universityEmail,
    required String level,
  }) async {
    try {
      final response = await _authService.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        matriculationNumber: matriculationNumber,
        universityEmail: universityEmail,
        level: level,
      );

      if (response.statusCode == 200) {
        final updatedUser = AcesStudent(
          id: _user?.id ?? '',
          name: fullName,
          email: _user?.email ?? '', 
          matNo: matriculationNumber,
          uniEmail: universityEmail,
          level: level,
        );

        _user = updatedUser;
        
        // Save updated profile to local database
        final token = await DBHelper.getToken();
        await DBHelper.saveProfile(updatedUser, token: token);
        
        notifyListeners();
        logger.i("Profile updated successfully");
        return true;
      } else {
        logger.e("Profile update failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      logger.e("Profile update error: $e");
      debugPrint("Profile update error: $e");
      return false;
    }
  }

  // Password recovery methods
Future<Map<String, dynamic>> forgotPassword(String email) async {
  try {
    final response = await _authService.forgotPassword(email);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _error = null;
      return {
        'success': true,
        'message': 'Password reset instructions sent to your email',
      };
    }

    return {
      'success': false,
      'message': response.data?['message'] ?? 'Failed to send reset instructions',
    };
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      return {
        'success': false,
        'message': 'Email not found. Please meet an ACES Admin to create your account.',
      };
    }

    return {
      'success': false,
      'message': e.response?.data?['message'] ?? 'Failed to send reset instructions',
    };
  } catch (e) {
    logger.e("Forgot password error: $e");
    return {
      'success': false,
      'message': 'Something went wrong. Please try again later.',
    };
  }
}

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      final response = await _authService.verifyCode(email, code);
      
      if (response.statusCode == 200 || response.statusCode ==201) {
        return {
          'success': true,
          'message': 'Code verified successfully'
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'Invalid verification code'
        };
      }
    } catch (e) {
      logger.e("Verify code error: $e");
      return {
        'success': false,
        'message': 'An error occurred. Please try again.'
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await _authService.resetPassword(email, code, newPassword);
      
      if (response.statusCode == 200 || response.statusCode ==201) {
        return {
          'success': true,
          'message': 'Password reset successfully'
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'Failed to reset password'
        };
      }
    } catch (e) {
      logger.e("Reset password error: $e");
      return {
        'success': false,
        'message': 'An error occurred. Please try again.'
      };
    }
  }

  Future<void> logout() async {
    _user = null;
    await DBHelper.clearProfile();
    notifyListeners();
  }
}