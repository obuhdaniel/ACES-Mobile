import 'package:aces_uniben/features/updates/models/updates_model.dart';
import 'package:aces_uniben/features/updates/updates_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/updates/providers/updates_provider.dart';

class MHSArticlesPage extends StatefulWidget {
  final UpdatesProvider provider;

  const MHSArticlesPage({Key? key, required this.provider}) : super(key: key);

  @override
  State<MHSArticlesPage> createState() => _MHSArticlesPageState();
}

class _MHSArticlesPageState extends State<MHSArticlesPage> 
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _showSearch = false;
  String _selectedFilter = 'All';
  
  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          _buildMHSArticlesList(),
        ],
      ),
      floatingActionButton: _buildScrollToTopFab(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'MHS Articles',
          style: GoogleFonts. poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1D29),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryTeal.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ),
     
    );
  }

  Widget _buildMHSArticlesList() {
    return Consumer<UpdatesProvider>(
      builder: (context, updatesProvider, child) {
        final articles = updatesProvider.mhsPosts?.entries.articles ?? [];

        if (articles.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildMHSArticleCard(
                  context, 
                  articles[index], 
                  updatesProvider,
                  index,
                );
              },
              childCount: articles.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMHSArticleCard(
    BuildContext context, 
    MHSArticle article, 
    UpdatesProvider provider,
    int index,
  ) {
    final delay = Duration(milliseconds: 100 * index);
    
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final animationProgress = Curves.easeOutCubic.transform(
          (_staggerController.value - (index * 0.1)).clamp(0.0, 1.0),
        );
        
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationProgress)),
          child: Opacity(
            opacity: animationProgress,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Hero(
          tag: 'mhs_article_${article.id}',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                UpdatesNavigationHandler.navigateToPostDetail(
                  context, 
                  article, 
                  'mhs_article',
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildCardContent(article),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(MHSArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (article.imageUrl != null) _buildCardImage(article),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(article),
              const SizedBox(height: 12),
              _buildCardTitle(article),
              const SizedBox(height: 8),
              _buildCardDescription(article),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardImage(MHSArticle article) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          Image.network(
            article.imageUrl!,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.article,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'MHS ARTICLE',
                    style: GoogleFonts. poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryTeal.withOpacity(0.3),
            Colors.blue.withOpacity(0.2),
          ],
        ),
      ),
      child: Icon(
        Icons.article_outlined,
        size: 48,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildCardHeader(MHSArticle article) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryTeal.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.article_outlined,
                size: 14,
                color: AppTheme.primaryTeal,
              ),
              const SizedBox(width: 4),
              Text(
                'MHS ARTICLE',
                style: GoogleFonts. poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTeal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _buildTimeIndicator(article),
      ],
    );
  }

  Widget _buildTimeIndicator(MHSArticle article) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            formatRelativeTime(article.updatedAt),
            style: GoogleFonts. poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTitle(MHSArticle article) {
    return Text(
      article.title,
      style: GoogleFonts. poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1D29),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCardDescription(MHSArticle article) {
    final description = article.description ?? '';
    if (description.isEmpty) return const SizedBox.shrink();
    
    return Text(
      description,
      style: GoogleFonts. poppins(
        fontSize: 14,
        color: const Color(0xFF64748B),
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }



  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts. poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.purple.shade800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 48,
              color: AppTheme.primaryTeal.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty 
              ? 'No MHS articles found'
              : 'No MHS articles yet',
            style: GoogleFonts. poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D29),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
              ? 'Try adjusting your search or filters'
              : 'Check back later for new mental health articles',
            style: GoogleFonts. poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                });
              },
              icon: const Icon(Icons.clear),
              label: Text(
                'Clear Filters',
                style: GoogleFonts. poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScrollToTopFab() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final showFab = _scrollController.hasClients && 
                       _scrollController.offset > 200;
        
        return AnimatedScale(
          scale: showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryTeal,
            elevation: 4,
            child: const Icon(Icons.keyboard_arrow_up),
          ),
        );
      },
    );
  }

  // Helper function to format relative time
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${(difference.inDays / 7).floor()}w ago';
  }
}