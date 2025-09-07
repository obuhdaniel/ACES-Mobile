import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/learn/models/tech_category_model.dart';
import 'package:aces_uniben/services/webview_widget.dart';
import 'package:flutter/material.dart';

class TechResourcesPage extends StatefulWidget {
  final TechCategory category;

  const TechResourcesPage({Key? key, required this.category}) : super(key: key);

  @override
  State<TechResourcesPage> createState() => _TechResourcesPageState();
}

class _TechResourcesPageState extends State<TechResourcesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final resources = widget.category.resources
        .where((res) => res.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryTeal,
        centerTitle: true,
        title: Text(
          widget.category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppTheme.primaryTeal,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryTeal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _query = val),
              style: TextStyle(
                color: AppTheme.textColor,
              ),
              decoration: InputDecoration(
                hintText: "What do you want to learn?",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                hintStyle: TextStyle(
                  color: Color(0xFF818094).withOpacity(0.8),

                ),
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Resources list
          Expanded(
            child: resources.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildResourceCard(context, resource),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No results found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, dynamic resource) {
    final isVideo = resource.type == 'youtube' || resource.type == 'video';
    final isPdf = resource.type == 'pdf';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebviewWidget(
              url: resource.url,
              title: resource.title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            
            
           _buildResourceThumbnail(resource, isVideo, isPdf),
                       const SizedBox(width: 12),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Type label
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '[ ${resource.type.toString().toUpperCase()}]',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isVideo
                      ? Colors.green
                      : isPdf
                          ? Colors.red
                          : AppTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildResourceThumbnail(dynamic resource, bool isVideo, bool isPdf) {
  Uri? uri;
  try {
    uri = Uri.parse(resource.url);
  } catch (_) {}

  String? faviconUrl;
  if (uri != null && uri.host.isNotEmpty) {
    faviconUrl = "${uri.scheme}://${uri.host}/favicon.ico";
  }

  return ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomLeft: Radius.circular(16),
    ),
    child: faviconUrl != null
        ? Image.network(
            faviconUrl,
            width: 100,
            height: 80,
            fit: BoxFit.contain, // so favicon isn't stretched
            errorBuilder: (context, error, stackTrace) {
              return _fallbackThumbnail(isVideo, isPdf);
            },
          )
        : _fallbackThumbnail(isVideo, isPdf),
  );
}

Widget _fallbackThumbnail(bool isVideo, bool isPdf) {
  return Container(
    width: 100,
    height: 80,
    color: AppTheme.primaryTeal.withOpacity(0.1),
    child: Icon(
      isVideo
          ? Icons.play_circle_fill
          : isPdf
              ? Icons.picture_as_pdf
              : Icons.description,
      color: isVideo
          ? Colors.green
          : isPdf
              ? Colors.red
              : AppTheme.primaryTeal,
      size: 40,
    ),
  );
}

}
