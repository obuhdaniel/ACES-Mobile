import 'package:aces_uniben/features/updates/models/updates_responses_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aces_uniben/features/updates/models/updates_model.dart';

class UpdatesDatabaseHelper {
  static final UpdatesDatabaseHelper _instance = UpdatesDatabaseHelper._internal();
  factory UpdatesDatabaseHelper() => _instance;
  UpdatesDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'updates_database.db');
    return await openDatabase(
      path,
      version: 3, // Incremented version for announcement tables
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Forum posts tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS forum_posts(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        imageUrl TEXT,
        updatedAt TEXT,
        isBookmarked INTEGER DEFAULT 0,
        type TEXT DEFAULT 'forum'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS forum_post_responses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        responseKey TEXT UNIQUE,
        total INTEGER,
        page INTEGER,
        pages INTEGER,
        lastUpdated TEXT,
        type TEXT DEFAULT 'forum'
      )
    ''');

    // MHS articles tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mhs_articles(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        imageUrl TEXT,
        updatedAt TEXT,
        volume TEXT,
        isBookmarked INTEGER DEFAULT 0,
        type TEXT DEFAULT 'mhs'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mhs_article_responses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        responseKey TEXT UNIQUE,
        total INTEGER,
        page INTEGER,
        pages INTEGER,
        lastUpdated TEXT,
        type TEXT DEFAULT 'mhs'
      )
    ''');

    // Announcement tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS announcements(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        imageUrl TEXT,
        updatedAt TEXT,
        isBookmarked INTEGER DEFAULT 0,
        type TEXT DEFAULT 'announcement'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS announcement_responses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        responseKey TEXT UNIQUE,
        total INTEGER,
        page INTEGER,
        pages INTEGER,
        lastUpdated TEXT,
        type TEXT DEFAULT 'announcement'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add MHS tables when upgrading from version 1 to 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS mhs_articles(
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          imageUrl TEXT,
          updatedAt TEXT,
          volume TEXT,
          isBookmarked INTEGER DEFAULT 0,
          type TEXT DEFAULT 'mhs'
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS mhs_article_responses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          responseKey TEXT UNIQUE,
          total INTEGER,
          page INTEGER,
          pages INTEGER,
          lastUpdated TEXT,
          type TEXT DEFAULT 'mhs'
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Add announcement tables when upgrading from version 2 to 3
      await db.execute('''
        CREATE TABLE IF NOT EXISTS announcements(
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          imageUrl TEXT,
          updatedAt TEXT,
          isBookmarked INTEGER DEFAULT 0,
          type TEXT DEFAULT 'announcement'
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS announcement_responses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          responseKey TEXT UNIQUE,
          total INTEGER,
          page INTEGER,
          pages INTEGER,
          lastUpdated TEXT,
          type TEXT DEFAULT 'announcement'
        )
      ''');
    }
  }

  // FORUM POSTS METHODS
  Future<void> insertForumPosts(ForumPostResponse response, {String responseKey = 'latest_forum'}) async {
    final db = await database;
    final batch = db.batch();

    batch.insert(
      'forum_post_responses',
      {
        'responseKey': responseKey,
        'total': response.total,
        'page': response.page,
        'pages': response.pages,
        'lastUpdated': DateTime.now().toIso8601String(),
        'type': 'forum',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final post in response.entries.posts) {
      batch.insert(
        'forum_posts',
        {
          'id': post.id,
          'title': post.title,
          'description': post.description,
          'imageUrl': post.imageUrl,
          'updatedAt': post.updatedAt.toIso8601String(),
          'isBookmarked': 0,
          'type': 'forum',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<ForumPostResponse?> getCachedForumPosts({String responseKey = 'latest_forum'}) async {
    final db = await database;

    final responseData = await db.query(
      'forum_post_responses',
      where: 'responseKey = ? AND type = ?',
      whereArgs: [responseKey, 'forum'],
    );

    if (responseData.isEmpty) return null;

    final postsData = await db.query(
      'forum_posts',
      where: 'type = ?',
      whereArgs: ['forum'],
    );

    final posts = postsData.map((data) => ForumPost(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String?,
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    )).toList();

    return ForumPostResponse(
      total: responseData.first['total'] as int,
      page: responseData.first['page'] as int,
      pages: responseData.first['pages'] as int,
      entries: ForumPostList(posts: posts),
    );
  }

  Future<void> updateForumPostBookmarkStatus(String postId, bool isBookmarked) async {
    final db = await database;
    await db.update(
      'forum_posts',
      {'isBookmarked': isBookmarked ? 1 : 0},
      where: 'id = ? AND type = ?',
      whereArgs: [postId, 'forum'],
    );
  }

  Future<List<ForumPost>> getBookmarkedForumPosts() async {
    final db = await database;
    final postsData = await db.query(
      'forum_posts',
      where: 'isBookmarked = ? AND type = ?',
      whereArgs: [1, 'forum'],
    );

    return postsData.map((data) => ForumPost(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String?,
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    )).toList();
  }

  // MHS ARTICLES METHODS
  Future<void> insertMHSArticles(MHSArticleResponse response, {String responseKey = 'latest_mhs'}) async {
    final db = await database;
    final batch = db.batch();

    batch.insert(
      'mhs_article_responses',
      {
        'responseKey': responseKey,
        'total': response.total,
        'page': response.page,
        'pages': response.pages,
        'lastUpdated': DateTime.now().toIso8601String(),
        'type': 'mhs',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final article in response.entries.articles) {
      batch.insert(
        'mhs_articles',
        {
          'id': article.id,
          'title': article.title,
          'description': article.description,
          'imageUrl': article.imageUrl,
          'updatedAt': article.updatedAt.toIso8601String(),
          'volume': article.volume,
          'isBookmarked': 0,
          'type': 'mhs',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<MHSArticleResponse?> getCachedMHSArticles({String responseKey = 'latest_mhs'}) async {
    final db = await database;

    final responseData = await db.query(
      'mhs_article_responses',
      where: 'responseKey = ? AND type = ?',
      whereArgs: [responseKey, 'mhs'],
    );

    if (responseData.isEmpty) return null;

    final articlesData = await db.query(
      'mhs_articles',
      where: 'type = ?',
      whereArgs: ['mhs'],
    );

    final articles = articlesData.map((data) => MHSArticle(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String?,
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      volume: data['volume'] as String,
    )).toList();

    return MHSArticleResponse(
      total: responseData.first['total'] as int,
      page: responseData.first['page'] as int,
      pages: responseData.first['pages'] as int,
      entries: MHSPostList(articles: articles),
    );
  }

  Future<void> updateMHSArticleBookmarkStatus(String articleId, bool isBookmarked) async {
    final db = await database;
    await db.update(
      'mhs_articles',
      {'isBookmarked': isBookmarked ? 1 : 0},
      where: 'id = ? AND type = ?',
      whereArgs: [articleId, 'mhs'],
    );
  }

  Future<List<MHSArticle>> getBookmarkedMHSArticles() async {
    final db = await database;
    final articlesData = await db.query(
      'mhs_articles',
      where: 'isBookmarked = ? AND type = ?',
      whereArgs: [1, 'mhs'],
    );

    return articlesData.map((data) => MHSArticle(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String?,
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      volume: data['volume'] as String,
    )).toList();
  }

  // ANNOUNCEMENT METHODS
  Future<void> insertAnnouncements(AnnouncementItemResponse response, {String responseKey = 'latest_announcement'}) async {
    final db = await database;
    final batch = db.batch();

    batch.insert(
      'announcement_responses',
      {
        'responseKey': responseKey,
        'total': response.total,
        'page': response.page,
        'pages': response.pages,
        'lastUpdated': DateTime.now().toIso8601String(),
        'type': 'announcement',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final announcement in response.entries.posts) {
      batch.insert(
        'announcements',
        {
          'id': announcement.id,
          'title': announcement.title,
          'description': announcement.description,
          'imageUrl': announcement.imageUrl,
          'updatedAt': announcement.updatedAt.toIso8601String(),
          'isBookmarked': 0,
          'type': 'announcement',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<AnnouncementItemResponse?> getCachedAnnouncements({String responseKey = 'latest_announcement'}) async {
    final db = await database;

    final responseData = await db.query(
      'announcement_responses',
      where: 'responseKey = ? AND type = ?',
      whereArgs: [responseKey, 'announcement'],
    );

    if (responseData.isEmpty) return null;

    final announcementsData = await db.query(
      'announcements',
      where: 'type = ?',
      whereArgs: ['announcement'],
    );

    final announcements = announcementsData.map((data) => AnnouncementItem(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String?,
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    )).toList();

    return AnnouncementItemResponse(
      total: responseData.first['total'] as int,
      page: responseData.first['page'] as int,
      pages: responseData.first['pages'] as int,
      entries: AnnouncementPostList(posts: announcements),
    );
  }

  Future<void> updateAnnouncementBookmarkStatus(String announcementId, bool isBookmarked) async {
    final db = await database;
    await db.update(
      'announcements',
      {'isBookmarked': isBookmarked ? 1 : 0},
      where: 'id = ? AND type = ?',
      whereArgs: [announcementId, 'announcement'],
    );
  }

  Future<List<AnnouncementItem>> getBookmarkedAnnouncements() async {
    final db = await database;
    final announcementsData = await db.query(
      'announcements',
      where: 'isBookmarked = ? AND type = ?',
      whereArgs: [1, 'announcement'],
    );

    return announcementsData.map((data) => AnnouncementItem(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String?,
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    )).toList();
  }

  // GENERAL METHODS
  Future<List<dynamic>> getAllBookmarks() async {
    final forumBookmarks = await getBookmarkedForumPosts();
    final mhsBookmarks = await getBookmarkedMHSArticles();
    final announcementBookmarks = await getBookmarkedAnnouncements();
    
    return [...forumBookmarks, ...mhsBookmarks, ...announcementBookmarks];
  }

  Future<void> clearForumCache() async {
    final db = await database;
    await db.delete('forum_posts');
    await db.delete('forum_post_responses');
  }

  Future<void> clearMHSCache() async {
    final db = await database;
    await db.delete('mhs_articles');
    await db.delete('mhs_article_responses');
  }

  Future<void> clearAnnouncementCache() async {
    final db = await database;
    await db.delete('announcements');
    await db.delete('announcement_responses');
  }

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('forum_posts');
    await db.delete('forum_post_responses');
    await db.delete('mhs_articles');
    await db.delete('mhs_article_responses');
    await db.delete('announcements');
    await db.delete('announcement_responses');
  }

  Future<bool> hasCachedForumPosts({String responseKey = 'latest_forum'}) async {
    final db = await database;
    final result = await db.query(
      'forum_post_responses',
      where: 'responseKey = ? AND type = ?',
      whereArgs: [responseKey, 'forum'],
    );
    return result.isNotEmpty;
  }

  Future<bool> hasCachedMHSArticles({String responseKey = 'latest_mhs'}) async {
    final db = await database;
    final result = await db.query(
      'mhs_article_responses',
      where: 'responseKey = ? AND type = ?',
      whereArgs: [responseKey, 'mhs'],
    );
    return result.isNotEmpty;
  }

  Future<bool> hasCachedAnnouncements({String responseKey = 'latest_announcement'}) async {
    final db = await database;
    final result = await db.query(
      'announcement_responses',
      where: 'responseKey = ? AND type = ?',
      whereArgs: [responseKey, 'announcement'],
    );
    return result.isNotEmpty;
  }
}