import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:trawallet_final_version/models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onUserTap;
  final bool isLast;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onUserTap,
    this.isLast = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      margin: EdgeInsets.only(bottom: widget.isLast ? 100 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(context),

          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(post.content, style: const TextStyle(fontSize: 15)),
            ),

          if (post.images.isNotEmpty) _buildImageCarousel(),

          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final post = widget.post;

    return InkWell(
      onTap: widget.onUserTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(post.userAvatar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildCategoryBadge(),
                    ],
                  ),
                  Row(
                    children: [
                      if (post.location != null) ...[
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          post.location!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        timeago.format(post.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final post = widget.post;

    String emoji;
    Color color;

    switch (post.category) {
      case 'photo':
        emoji = '📸';
        color = Colors.blue;
        break;
      case 'tip':
        emoji = '💡';
        color = Colors.orange;
        break;
      case 'review':
        emoji = '⭐';
        color = Colors.green;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 10)),
    );
  }

  // ⭐ INSTAGRAM-STYLE IMAGE CAROUSEL ⭐
  Widget _buildImageCarousel() {
    final images = widget.post.images;

    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Image.network(images[index], fit: BoxFit.cover);
            },
          ),
        ),

        // ⭐ Page Counter (like Instagram) ⭐
        if (images.length > 1)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_currentIndex + 1} / ${images.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final post = widget.post;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              post.isLikedByCurrentUser
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: post.isLikedByCurrentUser ? Colors.red : Colors.grey[700],
            ),
            onPressed: widget.onLike,
          ),
          Text(
            '${post.likesCount}',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),

          IconButton(
            icon: Icon(Icons.comment_outlined, color: Colors.grey[700]),
            onPressed: widget.onComment,
          ),
          Text(
            '${post.commentsCount}',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),

          Spacer(),

          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.grey[700]),
            onPressed: widget.onShare,
          ),
        ],
      ),
    );
  }
}
