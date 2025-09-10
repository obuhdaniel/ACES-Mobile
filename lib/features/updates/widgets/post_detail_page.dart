import 'package:aces_uniben/features/updates/updates_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aces_uniben/config/app_theme.dart';

class PostDetailPage extends StatefulWidget {
  final dynamic post;
  final String postType;

  const PostDetailPage({Key? key, required this.post, required this.postType}) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool isLiked = false;
  bool isBookmarked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));


    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: widget.post.imageUrl != null ? 300.0 : 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      flexibleSpace: FlexibleSpaceBar(
       
        background: widget.post.imageUrl != null 
          ? _buildHeroImage() 
          : _buildGradientBackground(),
      ),
    );
  }
Widget _buildHeroImage() {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImagePage(
            imageUrl: widget.post.imageUrl!,
            heroTag: 'post_image_${widget.post.id}',
          ),
        ),
      );
    },
    child: Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'post_image_${widget.post.id}',
          child: Image.network(
            widget.post.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildGradientBackground(),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryTeal.withOpacity(0.8),
            AppTheme.primaryTeal.withOpacity(0.6),
            Colors.blue.withOpacity(0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(),
            const SizedBox(height: 24),
            _buildPostTitle(),
            const SizedBox(height: 16),
            _buildPostMeta(),
            const SizedBox(height: 24),
            _buildPostContent(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getPostTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getPostTypeColor().withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPostTypeIcon(),
                size: 16,
                color: _getPostTypeColor(),
              ),
              const SizedBox(width: 6),
              Text(
                _getPostTypeLabel(),
                style: GoogleFonts. poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getPostTypeColor(),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formatRelativeTime(widget.post.updatedAt),
            style: GoogleFonts. poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostTitle() {
    return Text(
      widget.post.title,
      style: GoogleFonts. poppins(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A1D29),
        height: 1.2,
      ),
    );
  }

  Widget _buildPostMeta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
            child: const Icon(
              Icons.account_circle,
              color: AppTheme.primaryTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACES UNIBEN',
                  style: GoogleFonts. poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                Text(
                  'Published ${formatRelativeTime( widget.post.updatedAt)}',
                  style: GoogleFonts. poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildReadTime(),
        ],
      ),
    );
  }

  Widget _buildReadTime() {
    final wordCount = (widget.post.description ?? '').split(' ').length;
    final readTime = (wordCount / 200).ceil(); // Average reading speed
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${readTime}m read',
        style: GoogleFonts. poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText(
        widget.post.description ?? '',
        style: GoogleFonts. poppins(
          fontSize: 16,
          color: const Color(0xFF2D3748),
          height: 1.7,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          onPressed: _scrollToTop,
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryTeal,
          elevation: 4,
          child: const Icon(Icons.keyboard_arrow_up),
        )
       
      ],
    );
  }

  Color _getPostTypeColor() {
    switch (widget.postType) {
      case 'announcement':
        return const Color(0xFFE53E3E);
      case 'mhs_article':
        return const Color(0xFF3182CE);
      case 'forum_post':
        return const Color(0xFF38A169);
      default:
        return AppTheme.primaryTeal;
    }
  }

  IconData _getPostTypeIcon() {
    switch (widget.postType) {
      case 'announcement':
        return Icons.campaign_outlined;
      case 'mhs_article':
        return Icons.article_outlined;
      case 'forum_post':
        return Icons.forum_outlined;
      default:
        return Icons.post_add_outlined;
    }
  }

  String _getAppBarTitle() {
    switch (widget.postType) {
      case 'announcement':
        return 'Announcement';
      case 'mhs_article':
        return 'MHS Article';
      case 'forum_post':
        return 'Forum Post';
      default:
        return 'Post Details';
    }
  }

  String _getPostTypeLabel() {
    switch (widget.postType) {
      case 'announcement':
        return 'Announcement';
      case 'mhs_article':
        return 'MHS Article';
      case 'forum_post':
        return 'Forum Discussion';
      default:
        return 'Post';
    }
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    
    // Add haptic feedback
    if (isLiked) {
      // You can add haptic feedback here if available
      // HapticFeedback.lightImpact();
    }
  }

  void _toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBookmarked ? 'Post bookmarked' : 'Bookmark removed',
          style: GoogleFonts. poppins(),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _sharePost() {
    // Implement share functionality
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildShareBottomSheet(),
    );
  }

  Widget _buildShareBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Share Post',
            style: GoogleFonts. poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(Icons.copy, 'Copy Link', () {
                Navigator.pop(context);
                // Implement copy link
              }),
              _buildShareOption(Icons.message, 'Message', () {
                Navigator.pop(context);
                // Implement message share
              }),
              _buildShareOption(Icons.email, 'Email', () {
                Navigator.pop(context);
                // Implement email share
              }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryTeal),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts. poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text('Report Post', style: GoogleFonts. poppins()),
              onTap: () {
                Navigator.pop(context);
                // Implement report functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: Text('Hide Post', style: GoogleFonts. poppins()),
              onTap: () {
                Navigator.pop(context);
                // Implement hide functionality
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _scrollToTop() {
    // Implement scroll to top functionality
    // You'll need to add a ScrollController to implement this
  }
}


class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImagePage({
    Key? key,
    required this.imageUrl,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
