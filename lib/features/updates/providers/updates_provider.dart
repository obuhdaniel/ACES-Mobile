import 'package:aces_uniben/features/updates/services/updates_api_services.dart';
import 'package:aces_uniben/features/updates/services/updates_db_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:aces_uniben/features/updates/models/updates_model.dart';
import 'package:aces_uniben/features/updates/models/updates_responses_model.dart';
import 'package:logger/logger.dart';

class UpdatesProvider with ChangeNotifier {
  final UpdatesServices _updatesServices = UpdatesServices();
  final UpdatesDatabaseHelper _dbHelper = UpdatesDatabaseHelper();

  ForumPostResponse? _forumPosts;
  MHSArticleResponse? _mhsPosts;
  AnnouncementItemResponse? _announcementPosts;
  bool _isLoading = false;
  String? _error;
  bool _hasInternet = true;
  var logger = Logger();

  ForumPostResponse? get forumPosts => _forumPosts;
  MHSArticleResponse? get mhsPosts => _mhsPosts;
  AnnouncementItemResponse? get announcementPosts => _announcementPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInternet => _hasInternet;

  Future<void> fetchForumPosts({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final freshPosts = await _updatesServices.fetchForumPosts();
      _forumPosts = freshPosts;
      _hasInternet = true;

      await _dbHelper.insertForumPosts(freshPosts);
    } catch (e) {
      _hasInternet = false;

      if (!forceRefresh) {
        final cachedPosts = await _dbHelper.getCachedForumPosts();
        if (cachedPosts != null) {
          _forumPosts = cachedPosts;
          _error = 'Using cached data. No internet connection.';
        } else {
          _error = 'No internet connection and no cached data available.';
        }
      } else {
        _error = 'Failed to refresh: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMHSPosts({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final freshPosts = await _updatesServices.fetchMHSPosts();
      _mhsPosts = freshPosts;
      _hasInternet = true;

      await _dbHelper.insertMHSArticles(freshPosts);
    } catch (e) {
      _hasInternet = false;

      if (!forceRefresh) {
        final cachedPosts = await _dbHelper.getCachedMHSArticles();
        if (cachedPosts != null) {
          _mhsPosts = cachedPosts;
          _error = 'Using cached data. No internet connection.';
        } else {
          _error = 'No internet connection and no cached data available.';
        }
      } else {
        _error = 'Failed to refresh: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnnouncementPosts({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final freshPosts = await _updatesServices.fetchAnnouncementPosts();
      _announcementPosts = freshPosts;
      _hasInternet = true;

      await _dbHelper.insertAnnouncements(freshPosts);
    } catch (e) {
      _hasInternet = false;

      if (!forceRefresh) {
        final cachedPosts = await _dbHelper.getCachedAnnouncements();
        if (cachedPosts != null) {
          _announcementPosts = cachedPosts;
          _error = 'Using cached data. No internet connection.';
        } else {
          _error = 'No internet connection and no cached data available.';
        }
      } else {
        _error = 'Failed to refresh: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, List<dynamic>>> checkForNewUpdatesAndGetNewPosts() async {
  final Map<String, List<dynamic>> newPosts = {
    "forum": [],
    "mhs": [],
    "announcements": [],
  };

  try {
    // Get latest API posts
    final freshForumPosts = await _updatesServices.fetchForumPosts();
    final freshMhsPosts = await _updatesServices.fetchMHSPosts();
    final freshAnnouncements = await _updatesServices.fetchAnnouncementPosts();

    // Get cached posts
    final cachedForumPosts = await _dbHelper.getCachedForumPosts();
    final cachedMhsPosts = await _dbHelper.getCachedMHSArticles();
    final cachedAnnouncements = await _dbHelper.getCachedAnnouncements();

    // ✅ Compare Forum
    if (cachedForumPosts == null) {
      newPosts["forum"] = freshForumPosts.entries.posts;
    } else {
      final cachedIds = cachedForumPosts.entries.posts.map((e) => e.id).toSet();
      final freshOnes = freshForumPosts.entries.posts
          .where((post) =>
              !cachedIds.contains(post.id) ||
              _isNewer(post.updatedAt.toString(), cachedForumPosts.entries.posts))
          .toList();
      if (freshOnes.isNotEmpty) newPosts["forum"] = freshOnes;
    }

    // ✅ Compare MHS (use posts not articles)
    if (cachedMhsPosts == null) {
      newPosts["mhs"] = freshMhsPosts.entries.articles;
    } else {
      final cachedIds = cachedMhsPosts.entries.articles.map((e) => e.id).toSet();
      final freshOnes = freshMhsPosts.entries.articles
          .where((post) =>
              !cachedIds.contains(post.id) ||
              _isNewer(post.updatedAt.toString(), cachedMhsPosts.entries.articles))
          .toList();
      if (freshOnes.isNotEmpty) newPosts["mhs"] = freshOnes;
    }

    // ✅ Compare Announcements
    if (cachedAnnouncements == null) {
      newPosts["announcements"] = freshAnnouncements.entries.posts;
    } else {
      final cachedIds = cachedAnnouncements.entries.posts.map((e) => e.id).toSet();
      final freshOnes = freshAnnouncements.entries.posts
          .where((post) =>
              !cachedIds.contains(post.id) ||
              _isNewer(post.updatedAt.toString(), cachedAnnouncements.entries.posts))
          .toList();
      if (freshOnes.isNotEmpty) newPosts["announcements"] = freshOnes;
    }


      if (newPosts.values.any((list) => list.isNotEmpty)) {
      // ✅ only update cache AFTER detection
      await _dbHelper.insertForumPosts(freshForumPosts);
      await _dbHelper.insertMHSArticles(freshMhsPosts);
      await _dbHelper.insertAnnouncements(freshAnnouncements);
    }
  } catch (e) {
    debugPrint("Error checking new updates: $e");
  }

  logger.d('new posts are $newPosts');
  return newPosts;
}

/// Helper: check if a post has a newer updatedAt than cached ones
bool _isNewer(String? updatedAt, List<dynamic> cached) {
  if (updatedAt == null) return false;
  try {
    final postDate = DateTime.tryParse(updatedAt);
    if (postDate == null) return false;
    final latestCached = cached
        .map((p) => DateTime.tryParse(p.updatedAt ?? ""))
        .whereType<DateTime>()
        .fold<DateTime?>(null, (prev, date) =>
            prev == null || date.isAfter(prev) ? date : prev);
    return latestCached == null || postDate.isAfter(latestCached);
  } catch (_) {
    return false;
  }
}
  // Toggle bookmark status
  Future<void> toggleBookmark(String postId) async {
    if (_forumPosts == null) return;

    final updatedPosts = _forumPosts!.entries.posts.map((post) {
      if (post.id == postId) {
        return ForumPost(
          id: post.id,
          title: post.title,
          description: post.description,
          imageUrl: post.imageUrl,
          updatedAt: post.updatedAt,
        );
      }
      return post;
    }).toList();

    _forumPosts = ForumPostResponse(
      total: _forumPosts!.total,
      page: _forumPosts!.page,
      pages: _forumPosts!.pages,
      entries: ForumPostList(posts: updatedPosts),
    );

    final isCurrentlyBookmarked = await _isPostBookmarked(postId);
    await _dbHelper.updateForumPostBookmarkStatus(postId, !isCurrentlyBookmarked);

    notifyListeners();
  }

  Future<void> toggleAnnouncementBookmark(String postId) async {
    if (_announcementPosts == null) return;

    final updatedPosts = _announcementPosts!.entries.posts.map((post) {
      if (post.id == postId) {
        return AnnouncementItem(
          id: post.id,
          title: post.title,
          description: post.description,
          imageUrl: post.imageUrl,
          updatedAt: post.updatedAt,
        );
      }
      return post;
    }).toList();

    _announcementPosts = AnnouncementItemResponse(
      total: _announcementPosts!.total,
      page: _announcementPosts!.page,
      pages: _announcementPosts!.pages,
      entries: AnnouncementPostList(posts: updatedPosts),
    );

    final isCurrentlyBookmarked = await _isAnnouncementBookmarked(postId);
    await _dbHelper.updateAnnouncementBookmarkStatus(postId, !isCurrentlyBookmarked);

    notifyListeners();
  }

  Future<bool> _isAnnouncementBookmarked(String postId) async {
    final bookmarkedPosts = await _dbHelper.getBookmarkedAnnouncements();
    return bookmarkedPosts.any((post) => post.id == postId);
  }

  Future<bool> isAnnouncementBookmarked(String postId) async {
    final bookmarkedPosts = await _dbHelper.getBookmarkedAnnouncements();
    return bookmarkedPosts.any((post) => post.id == postId);
  }

  Future<bool> _isPostBookmarked(String postId) async {
    final bookmarkedPosts = await _dbHelper.getBookmarkedForumPosts();
    return bookmarkedPosts.any((post) => post.id == postId);
  }

  Future<List<ForumPost>> getBookmarkedPosts() async {
    return await _dbHelper.getBookmarkedForumPosts();
  }

  Future<List<AnnouncementItem>> getBookmarkedAnnouncements() async {
    return await _dbHelper.getBookmarkedAnnouncements();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchForumPosts(forceRefresh: true);
  }

  Future<bool> hasCachedForumData() async {
    return await _dbHelper.hasCachedForumPosts();
  }
}
