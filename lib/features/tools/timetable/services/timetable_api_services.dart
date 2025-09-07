import 'package:aces_uniben/config/api_config.dart';
import 'package:aces_uniben/features/tools/timetable/models/timetabole_data_model.dart';
import 'package:aces_uniben/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class TimeTableApiService {
   final Dio _dio = DioClient.dio;
  final Logger _logger = Logger();


  Future<TimeTableResponse> fetchTimeTable() async {
    try {
      final response = await _dio.get(
        ApiConfig.timetableEndpoint,
      );

      _logger.i("Timetable fetch successful");
      _logger.d("Response: ${response.data}");

      final timeTableResponse = TimeTableResponse.fromJson(response.data);
      return timeTableResponse;
      
    } on DioException catch (dioError) {
      _logger.e("Timetable fetch failed: ${dioError.message}");
      if (dioError.response != null) {
        _logger.e("Status: ${dioError.response?.statusCode}, Data: ${dioError.response?.data}");
      }
      rethrow;
    } catch (e) {
      _logger.e("Unexpected timetable fetch error: $e");
      rethrow;
    }
  }
}
