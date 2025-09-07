
// Data models - replace with your actual models
class NewsItem {
  final String title;
  final String category;
  final String timeAgo;
  final String? imageUrl;

  NewsItem({
    required this.title,
    required this.category,
    required this.timeAgo,
    this.imageUrl,
  });
}

class AnnouncementItem {
  final String title;
  final String? imageUrl;
  final String id;
  final String description;
  final DateTime updatedAt;

  AnnouncementItem({
    required this.title,
    required this.description,
    required this.id,
    required this.updatedAt,
    this.imageUrl,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      title: json['title'],
      id: json['id'],
      description: json['Description'],
      updatedAt: DateTime.parse(json['updatedAt']),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
      'Description': description,
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

class AnnouncementPostList {
  final List<AnnouncementItem> posts;

  AnnouncementPostList({required this.posts});

  factory AnnouncementPostList.fromJson(List<dynamic> json) {
    return AnnouncementPostList(
      posts: json.map((post) => AnnouncementItem.fromJson(post)).toList(),
    );
  }
}

class MHSArticle {
 final String title;
  final String? imageUrl;
  final String id;
  final String description;
  final DateTime updatedAt;
  final String volume;

  MHSArticle({
    required this.title,
    this.imageUrl,
    required this.id,
    required this.description,
    required this.updatedAt,
    required this.volume,
  });

   factory MHSArticle.fromJson(Map<String, dynamic> json) {
    return MHSArticle(
      title: json['title'],
      id: json['id'],
      description: json['Description'],
      updatedAt: DateTime.parse(json['updatedAt']),
      imageUrl: json['imageUrl'],
      volume: json['volume'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
      'Description': description,
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'volume': volume,
    };
  }
}


class MHSPostList {
  final List<MHSArticle> articles;

  MHSPostList({required this.articles});

  factory MHSPostList.fromJson(List<dynamic> json) {
    return MHSPostList(
      articles: json.map((post) => MHSArticle.fromJson(post)).toList(),
    );
  }
}


// updates_model.dart
class ForumPost {
  final String title;
  final String? imageUrl;
  final String id;
  final String description;
  final DateTime updatedAt;

  ForumPost({
    required this.title,
    this.imageUrl,
    required this.id,
    required this.description,
    required this.updatedAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      title: json['title'],
      id: json['id'],
      description: json['Description'],
      updatedAt: DateTime.parse(json['updatedAt']),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
      'Description': description,
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

class ForumPostList {
  final List<ForumPost> posts;

  ForumPostList({required this.posts});

  factory ForumPostList.fromJson(List<dynamic> json) {
    return ForumPostList(
      posts: json.map((post) => ForumPost.fromJson(post)).toList(),
    );
  }
}




