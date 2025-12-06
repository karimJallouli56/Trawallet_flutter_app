import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/post.dart';
import 'package:trawallet_final_version/views/community/add_post_card.dart';
import 'package:trawallet_final_version/views/community/add_post_screen.dart';
import 'package:trawallet_final_version/views/community/postCard.dart';
import 'package:trawallet_final_version/views/community/comment_screen.dart';
import 'package:trawallet_final_version/views/home/components/navbar.dart';

// ============================================================================
// FEED SCREEN
// ============================================================================

class TravelFeedScreen extends StatefulWidget {
  const TravelFeedScreen({super.key});

  @override
  State<TravelFeedScreen> createState() => _TravelFeedScreenState();
}

class _TravelFeedScreenState extends State<TravelFeedScreen> {
  String _selectedFilter = 'All';
  final ScrollController _scrollController = ScrollController();
  List<Post> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  // Simulate loading posts (replace with Firebase call)
  // Example with Firebase
  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    setState(() {
      _posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
      _isLoading = false;
    });
  }

  Future<void> _loadMorePosts() async {
    // Pagination logic here
  }

  Future<void> _refreshFeed() async {
    await _loadPosts();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadPosts();
  }

  void _onLikePressed(Post post) {
    setState(() {
      final index = _posts.indexWhere((p) => p.postId == post.postId);
      if (index != -1) {
        _posts[index] = post.copyWith(
          isLikedByCurrentUser: !post.isLikedByCurrentUser,
          likesCount: post.isLikedByCurrentUser
              ? post.likesCount - 1
              : post.likesCount + 1,
        );
      }
    });

    // TODO: Update like in backend
  }

  void _onCommentPressed(Post post) {
    // Navigate to comments screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommentsScreen(post: post)),
    );
  }

  void _onSharePressed(Post post) {
    // Share post logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _onUserProfilePressed(Post post) {
    // Navigate to user profile
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to ${post.username}\'s profile')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Navbar(
      activeScreenId: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        appBar: AppBar(
          title: const Text(
            'Travel Community',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Search functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Notifications
              },
            ),
          ],
        ),

        body: Column(
          children: [
            SizedBox(
              height: 10,
              width: size.width,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
            // Filter Tabs
            _buildFilterTabs(),
            // In your feed screen
            AddPostCard(
              userAvatar:
                  'https://nydkmuqxbdmosymchola.supabase.co/storage/v1/object/public/post-images/avatars/avatar_default_man.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPostScreen(
                      userAvatar:
                          'https://nydkmuqxbdmosymchola.supabase.co/storage/v1/object/public/post-images/avatars/avatar_default_man.png',
                      username: 'John Doe',
                      userId: 'ffff',
                    ),
                  ),
                ).then((result) {
                  if (result != null) {
                    // Handle the created post data
                    print('Content: ${result['content']}');
                    print('Images: ${result['images']}');
                    print('Location: ${result['location']}');
                    print('Category: ${result['category']}');
                  }
                });
              },
            ),

            // Feed
            Expanded(
              child: _isLoading && _posts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshFeed,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 2),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            post: _posts[index],
                            onLike: () => _onLikePressed(_posts[index]),
                            onComment: () => _onCommentPressed(_posts[index]),
                            onShare: () => _onSharePressed(_posts[index]),
                            onUserTap: () =>
                                _onUserProfilePressed(_posts[index]),
                            isLast: index == _posts.length - 1,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Following', 'Photos', 'Tips', 'Reviews'];

    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) _onFilterChanged(filter);
              },
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              selectedColor: Colors.teal.shade700,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Dummy data generator
  List<Post> _getDummyPosts() {
    return [
      Post(
        postId: '1',
        userId: 'user1',
        username: 'TravelExplorer',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        content:
            'Just visited the stunning Eiffel Tower! The sunset view from the top is absolutely breathtaking. Highly recommend visiting during golden hour! 🗼✨',
        images: [
          'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800',
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
        ],
        location: 'Paris, France',
        category: 'photo',
        likesCount: 245,
        commentsCount: 32,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        postId: '2',
        userId: 'user2',
        username: 'AdventureSeeker',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        content:
            'Pro tip: Always book your accommodations at least 2 months in advance for popular destinations. Saved 40% on my Tokyo hotel! 💡',
        images: [],
        location: 'Tokyo, Japan',
        category: 'tip',
        likesCount: 156,
        commentsCount: 18,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Post(
        postId: '3',
        userId: 'user3',
        username: 'Wanderlust_Sarah',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        content:
            'Santorini exceeded all expectations! The blue domes, white buildings, and crystal clear waters create the perfect paradise. Already planning my return trip! 🇬🇷',
        images: [
          'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=800',
        ],
        location: 'Santorini, Greece',
        category: 'review',
        likesCount: 412,
        commentsCount: 56,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isLikedByCurrentUser: true,
      ),
      Post(
        postId: '4',
        userId: 'user4',
        username: 'GlobalNomad',
        userAvatar: 'https://i.pravatar.cc/150?img=4',
        content:
            'Hiking the Inca Trail was challenging but absolutely worth it! The view of Machu Picchu at sunrise is something everyone should experience at least once in their lifetime. 🏔️',
        images: [
          'https://images.unsplash.com/photo-1587595431973-160d0d94add1?w=800',
          'https://images.unsplash.com/photo-1526392060635-9d6019884377?w=800',
        ],
        location: 'Machu Picchu, Peru',
        category: 'photo',
        likesCount: 589,
        commentsCount: 71,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}


// ============================================================================
// PLACEHOLDER COMMENTS SCREEN
// ============================================================================

