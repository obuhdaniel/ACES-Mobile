import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/notifications/notification_service.dart';
import 'package:aces_uniben/features/updates/models/updates_model.dart';
import 'package:aces_uniben/features/updates/providers/updates_provider.dart';
import 'package:aces_uniben/features/updates/widgets/announcement_page.dart';
import 'package:aces_uniben/features/updates/widgets/forum_posts_page.dart';
import 'package:aces_uniben/features/updates/widgets/mhs_articles_page.dart';
import 'package:aces_uniben/features/updates/widgets/post_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';



//NAVIGATION HANDLER
class UpdatesNavigationHandler {
  static void navigateToAnnouncements(BuildContext context, UpdatesProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementsPage(provider: provider),
      ),
    );
  }

  static void navigateToMHSArticles(BuildContext context, UpdatesProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MHSArticlesPage(provider: provider),
      ),
    );
  }

  static void navigateToForumPosts(BuildContext context, UpdatesProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumPostsPage(provider: provider),
      ),
    );
  }

  static void navigateToPostDetail(BuildContext context, dynamic post, String postType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post: post, postType: postType),
      ),
    );
  }
}





class UpdatesPage extends StatefulWidget {
  const UpdatesPage({Key? key}) : super(key: key);

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  bool isLoading = false;

  

  @override
  void initState() {
    super.initState();
    
    _checkForUpdates();

    _loadData();
    
  }


  Future<void> _checkForUpdates() async {
  final provider = Provider.of<UpdatesProvider>(context, listen: false);

  final newPosts = await provider.checkForNewUpdatesAndGetNewPosts();

  if (newPosts["forum"]!.isNotEmpty) {
      final latestForum = newPosts["forum"]!.first;
      NotificationService().showImageNotification(
        id: 101,
        title: "New Forum Post!",
        body: latestForum.title,
        imageUrl: latestForum.imageUrl
      );
    }

    if (newPosts["announcements"]!.isNotEmpty) {
      final latestAnn = newPosts["announcements"]!.first;
      NotificationService().showImageNotification(
        id: 102,
        title: "New Announcement!",
        body: latestAnn.title,
        imageUrl: latestAnn.imageUrl
      );
    }

    if (newPosts["mhs"]!.isNotEmpty) {
      final latestMhs = newPosts["mhs"]!.first;
      NotificationService().showImageNotification(
        id: 103,
        title: "New MHS Article!",
        body: latestMhs.title,
        imageUrl: latestMhs.imageUrl

      );
    }
}

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final updatesProvider = Provider.of<UpdatesProvider>(context, listen: false);
    await updatesProvider.fetchForumPosts();
    await updatesProvider.fetchMHSPosts();
    await updatesProvider.fetchAnnouncementPosts();
    final newPosts = await updatesProvider.checkForNewUpdatesAndGetNewPosts();

  if (newPosts["forum"]!.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("New forum post: ${newPosts['forum']!.first.title}")),
    );
  }
    setState(() => isLoading = false);
  }

  Future<void> _refreshData() async {
    await _checkForUpdates();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      
      title: Text(
        'Updates',
        style: GoogleFonts. poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryTeal,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildLatestNewsSection(),
          // const SizedBox(height: 24),
          _buildAnnouncementsSection(),
          const SizedBox(height: 24),
          _buildMHSArticlesSection(),
          const SizedBox(height: 24),
          _buildForumSection(),
          const SizedBox(height: 80), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts. poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTeal,
            ),

          ),
          Spacer(),
          TextButton(onPressed: onSeeAll, child: Text(
            'See All',
            style: GoogleFonts. poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor.withOpacity(0.6),
            ),

          ),)
        ],
      ),
    );
  }
  
  Widget _buildAnnouncementsSection() {
  return Consumer<UpdatesProvider>(
    builder: (context, updatesProvider, child) {
      final announcementResponse = updatesProvider.announcementPosts;
      final announcements = announcementResponse?.entries.posts ?? [];
      
      final mainAnnouncement = announcements.isNotEmpty ? announcements.first : null;
      final otherAnnouncements = announcements.length > 1
          ? announcements.sublist(1)
          : [];

      // Show loading state
      if (updatesProvider.isLoading) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Announcements', () {}),
            const SizedBox(height: 16),
            _buildLoadingShimmer(),
          ],
        );
      }

      // Show error state
      if (updatesProvider.error != null && announcements.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Announcements', () {
              updatesProvider.refresh();
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    updatesProvider.error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts. poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => updatesProvider.refresh(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      // Show empty state
      if (announcements.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Announcements', () {
              updatesProvider.refresh();
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
              ),
              child: Column(
                children: [
                  const Icon(Icons.announcement, color: Colors.grey, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'No announcements available',
                    style: GoogleFonts. poppins(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      // Show announcements data
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Announcements', () {
            UpdatesNavigationHandler.navigateToAnnouncements(context, updatesProvider);
          }),
          const SizedBox(height: 16),

          if (mainAnnouncement != null)
            _buildMainAnnouncementCard(mainAnnouncement, updatesProvider),

          const SizedBox(height: 16),

          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: otherAnnouncements.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return _buildSmallAnnouncementCard(otherAnnouncements[index], updatesProvider);
            },
          ),
        ],
      );
    },
  );
}

Widget _buildMainAnnouncementCard(AnnouncementItem announcement, UpdatesProvider provider) {
  return GestureDetector(
    onTap: () {
      UpdatesNavigationHandler.navigateToPostDetail(context, announcement, 'announcement');
    },
    child: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: announcement.imageUrl != null
                    ? Image.network(
                        announcement.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.orangeAccent.withOpacity(0.2),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.orangeAccent.withOpacity(0.2),
                        child: _buildImagePlaceholder(),
                      ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: GoogleFonts. poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcement.description,
                      style: GoogleFonts. poppins(
                        fontSize: 15,
                        color: AppTheme.textColor,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child:  Text(
                        'View More',
                        style: GoogleFonts.poppins(
                          color: Color(0xFF2E7D8F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSmallAnnouncementCard(AnnouncementItem announcement, UpdatesProvider provider) {
  return GestureDetector(
    onTap: () {
      UpdatesNavigationHandler.navigateToPostDetail(context, announcement, 'announcement');
    },
    child: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: announcement.imageUrl != null
                    ? Image.network(
                        announcement.imageUrl!,
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Container(
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: _buildImagePlaceholder(),
                          ),
                      )
                    : Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: _buildImagePlaceholder(),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: GoogleFonts. poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.description,
                      style: GoogleFonts. poppins(
                        fontSize: 14,
                        color: const Color(0xFF696984),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ],
    ),
  );
}

// Helper method for loading shimmer
Widget _buildLoadingShimmer() {
  return Column(
    children: [
      // Main card shimmer
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade200,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 16,
                    width: 200,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildMHSArticlesSection() {
    return Consumer<UpdatesProvider>(
      builder: (context, updatesProvider, child) {

        if (updatesProvider.mhsPosts == null || updatesProvider.mhsPosts!.entries.articles.isEmpty) {
            return const Center(child: Text('No forum posts available.'));
          }

          final posts = updatesProvider.mhsPosts!.entries.articles;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('MHS Article', () {
             UpdatesNavigationHandler.navigateToMHSArticles(context, updatesProvider);
            }),
            ...posts.map((article) => _buildMHSArticleCard(article)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMHSArticleCard(MHSArticle article) {
    return GestureDetector(
      onTap: () {
        UpdatesNavigationHandler.navigateToPostDetail(context, article, 'mhs_article');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts. poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                      children: [
                        // Text(
                        //   'MHS Article',
                        //   style: GoogleFonts. poppins(
                        //     fontSize: 10,
                        //     color: AppTheme.textColor.withOpacity(0.8),
                        //   ),
                        // ),
                        // const SizedBox(width: 8),
                        const Icon(
                          Icons.circle,
                          size: 14,
                          color: AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatRelativeTime(article.updatedAt),
                          style: GoogleFonts. poppins(
                            fontSize: 14,
                            color: const Color(0xFF8F9BB3),
                          ),
                        ),
                      ],
                    ),
                  
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: article.imageUrl != null
                    ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildForumSection() {
  return Consumer<UpdatesProvider>(
    builder: (context, updatesProvider, child) {
      final forumPosts = updatesProvider.forumPosts?.entries.posts ?? [];
      final hasForumPosts = forumPosts.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Forum', () {
            UpdatesNavigationHandler.navigateToForumPosts(context, updatesProvider);
          }),
          hasForumPosts
              ? SizedBox(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forumPosts.length > 5 ? 6 : forumPosts.length,
                    itemBuilder: (context, index) {
                      if (index == 5) {
                        return _buildViewMoreCard();
                      }
                      return _buildForumCard(forumPosts[index]);
                    },
                  ),
                )
              : const Center(child: Text('No forum posts available.')),
        ],
      );
    },
  );
}

Widget _buildViewMoreCard() {
  return GestureDetector(
    onTap: () {
      // Logic to navigate to the full forum page.
      // For example: Navigator.of(context).push(MaterialPageRoute(builder: (_) => ForumPage()));
    },
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 200, // or whatever width your cards are
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward),
              SizedBox(height: 8.0),
              Text('View More'),
            ],
          ),
        ),
      ),
    ),
  );
}  

Widget _buildForumCard(ForumPost post) {
    return GestureDetector(
        onTap: () {
      
      UpdatesNavigationHandler.navigateToPostDetail(context, post, 'forum_post');
    },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 170,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: post.imageUrl != null
                    ? Image.network(
                        post.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: GoogleFonts. poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                     Row(
                      children: [
                        Text(
                          'Forum',
                          style: GoogleFonts. poppins(
                            fontSize: 14,
                            color: AppTheme.textColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.circle,
                          size: 14,
                          color: AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                           formatRelativeTime(post.updatedAt),
                          style: GoogleFonts. poppins(
                            fontSize: 14,
                            color: const Color(0xFF8F9BB3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }

  // Mock data - replace with actual API calls
  List<NewsItem> _getMockLatestNews() {
    return [
      NewsItem(
        title: 'ACES Mental Health Scheme (MHS) Week 1 Article',
        category: 'MHS Article',
        timeAgo: '4min ago',
        imageUrl: null,
      ),
      NewsItem(
        title: 'ACES Mental Health Scheme (MHS) Week 2 Article',
        category: 'MHS Article',
        timeAgo: '1hr ago',
        imageUrl: null,
      ),
    ];
  }


  List<ForumPost> _getMockForumPosts() {
    return [
      ForumPost(
        title: 'Happy Birthday Timothy Ofuje',
        description: 'Forum',
        updatedAt: DateTime.parse('2023-03-01T12:00:00Z'),
        imageUrl: null,
        id: '1',
      ),
      ForumPost(
        title: 'Happy Birthday Idris',
        description: 'Forum',
        updatedAt: DateTime.parse('2023-03-01T12:00:00Z'),
        imageUrl: null,
        id: '2'
      ),
    ];
  }
}


String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 7) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  } else if (difference.inDays > 1) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inHours > 1) {
    return '${difference.inHours} hours ago';
  } else if (difference.inHours == 1) {
    return 'An hour ago';
  } else if (difference.inMinutes > 1) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inMinutes == 1) {
    return 'A minute ago';
  } else {
    return 'Just now';
  }
}
