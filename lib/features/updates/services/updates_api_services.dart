
import 'package:aces_uniben/features/updates/models/updates_model.dart';
import 'package:aces_uniben/features/updates/models/updates_responses_model.dart';
import 'package:aces_uniben/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class UpdatesServices {
  final Dio _dio = DioClient.dio;
  final Logger _logger = Logger();

  Future<ForumPostResponse> fetchForumPosts() async {
    try {
      final response = await _dio.get(
        'https://aces-utky.onrender.com/api/admin/forum/read?page=1&limit=100',
      );

      _logger.d("Response: ${response.data}");

      return ForumPostResponse(
        total: response.data['total'],
        page: response.data['page'],
        pages: response.data['pages'],
        entries: ForumPostList(
          posts: (response.data['entries'] as List)
              .map((postJson) => ForumPost.fromJson(postJson))
              .toList(),
        ),
      );
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


  Future<MHSArticleResponse> fetchMHSPosts() async {
    try {
      final response = await _dio.get(
        'https://aces-utky.onrender.com/api/admin/acesmhs/read?page=1&limit=100',
      );

      _logger.d("Response: ${response.data}");

      return MHSArticleResponse(
        total: response.data['total'],
        page: response.data['page'],
        pages: response.data['pages'],
        entries: MHSPostList(
          articles: (response.data['entries'] as List)
              .map((postJson) => MHSArticle.fromJson(postJson))
              .toList(),
        ),
      );
    } on DioException catch (dioError) {
      _logger.e("Fetch failed: ${dioError.message}");
      if (dioError.response != null) {
        _logger.e("Status: ${dioError.response?.statusCode}, Data: ${dioError.response?.data}");
      }
      rethrow;
    } catch (e) {
      _logger.e("Unexpected login error: $e");
      rethrow;
    }
  }


  Future<AnnouncementItemResponse> fetchAnnouncementPosts() async {
    try {
      final response = await _dio.get(
        'https://aces-utky.onrender.com/api/admin/blog/read?page=1&limit=100',
      );

      _logger.d("Response: ${response.data}");

      return AnnouncementItemResponse(
        total: response.data['total'],
        page: response.data['page'],
        pages: response.data['pages'],
        entries: AnnouncementPostList(
          posts: (response.data['entries'] as List)
              .map((postJson) => AnnouncementItem.fromJson(postJson))
              .toList(),
        ),
      );
    } on DioException catch (dioError) {
      _logger.e("Fetch failed: ${dioError.message}");
      if (dioError.response != null) {
        _logger.e("Status: ${dioError.response?.statusCode}, Data: ${dioError.response?.data}");
      }
      rethrow;
    } catch (e) {
      _logger.e("Unexpected login error: $e");
      rethrow;
    }
  }





}