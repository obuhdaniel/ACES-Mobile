import 'package:aces_uniben/features/updates/models/updates_model.dart';

class ForumPostResponse {
  final int total;
  final int page;
  final int pages;
  final ForumPostList entries;

  ForumPostResponse({
    required this.total,
    required this.page,
    required this.pages,
    required this.entries,
  });
}


class MHSArticleResponse {
  final int total;
  final int page;
  final int pages;
  final MHSPostList entries;

  MHSArticleResponse({
    required this.total,
    required this.page,
    required this.pages,
    required this.entries,
  });
}

class AnnouncementItemResponse {
  final int total;
  final int page;
  final int pages;
  final AnnouncementPostList entries;

  AnnouncementItemResponse({
    required this.total,
    required this.page,
    required this.pages,
    required this.entries,
  });
}