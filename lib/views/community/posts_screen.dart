import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/post.dart';
import 'package:trawallet_final_version/models/appUser.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'package:trawallet_final_version/services/user_service.dart';
import 'package:trawallet_final_version/views/community/add_post_card.dart';
import 'package:trawallet_final_version/views/community/add_post_screen.dart';
import 'package:trawallet_final_version/views/community/postCard.dart';
import 'package:trawallet_final_version/views/community/comment_screen.dart';
import 'package:trawallet_final_version/views/home/components/navbar.dart';

class TravelFeedScreen extends StatefulWidget {
  const TravelFeedScreen({super.key});

  @override
  State<TravelFeedScreen> createState() => _TravelFeedScreenState();
}

class _TravelFeedScreenState extends State<TravelFeedScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // String _selectedFilter = 'All';
  final ScrollController _scrollController = ScrollController();
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isLoadingUser = true;
  String? _currentUserId;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoadingUser = true);

    final user = _authService.currentUser;
    if (user == null) {
      setState(() => _isLoadingUser = false);
      return;
    }

    _currentUserId = user.uid;

    try {
      final appUser = await _userService.getUserById(user.uid);
      setState(() {
        _currentUser = appUser;
        _isLoadingUser = false;
      });

      // Load posts after user data is loaded
      _loadPosts();
    } catch (e) {
      print('Error loading user: $e');
      setState(() => _isLoadingUser = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more posts here if implementing pagination
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    final currentUserId = _authService.currentUser?.uid;

    if (currentUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      setState(() {
        _posts = snapshot.docs
            .map((doc) => Post.fromFirestoreWithUser(doc, currentUserId))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshFeed() async {
    await _loadPosts();
  }

  // void _onFilterChanged(String filter) {
  //   setState(() {
  //     _selectedFilter = filter;
  //   });
  //   _loadPosts();
  // }

  Future<void> _onLikePressed(Post post) async {
    final currentUserId = _authService.currentUser?.uid;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to like posts'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedLikedBy = List<String>.from(post.likedBy);
    final bool willBeLiked = !post.isLikedByCurrentUser;

    if (willBeLiked) {
      updatedLikedBy.add(currentUserId);
    } else {
      updatedLikedBy.remove(currentUserId);
    }

    setState(() {
      final index = _posts.indexWhere((p) => p.postId == post.postId);
      if (index != -1) {
        _posts[index] = post.copyWith(
          isLikedByCurrentUser: willBeLiked,
          likesCount: willBeLiked ? post.likesCount + 1 : post.likesCount - 1,
          likedBy: updatedLikedBy,
        );
      }
    });

    try {
      await Post.toggleLike(post.postId, currentUserId);
    } catch (e) {
      print('Error toggling like: $e');

      setState(() {
        final index = _posts.indexWhere((p) => p.postId == post.postId);
        if (index != -1) {
          _posts[index] = post;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update like'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onCommentPressed(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommentsScreen(post: post)),
    );
  }

  void _onSharePressed(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _onUserProfilePressed(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to ${post.username}\'s profile')),
    );
  }

  void _onAddPostTap() {
    if (_currentUser == null || _currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while we load your profile'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(
          userAvatar:
              _currentUser!.userAvatar ??
              'https://nydkmuqxbdmosymchola.supabase.co/storage/v1/object/public/post-images/avatars/avatar_default_man.png',
          username: _currentUser!.username,
          userId: _currentUserId!,
        ),
      ),
    ).then((result) {
      if (result != null) {
        _refreshFeed();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Navbar(
      activeScreenId: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Travel Community',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.teal,
          scrolledUnderElevation: 0,
        ),
        body: _isLoadingUser
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : Column(
                children: [
                  SizedBox(
                    height: 10,
                    width: size.width,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white),
                    ),
                  ),
                  AddPostCard(
                    userAvatar:
                        _currentUser?.userAvatar ??
                        'https://nydkmuqxbdmosymchola.supabase.co/storage/v1/object/public/post-images/avatars/avatar_default_man.png',
                    onTap: _onAddPostTap,
                  ),
                  Expanded(
                    child: _isLoading && _posts.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.teal,
                            ),
                          )
                        : _posts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.explore_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No posts yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to share your travel story!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            backgroundColor: Colors.white,
                            color: Colors.teal,
                            onRefresh: _refreshFeed,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 2),
                              itemCount: _posts.length,
                              itemBuilder: (context, index) {
                                return PostCard(
                                  post: _posts[index],
                                  onLike: () => _onLikePressed(_posts[index]),
                                  onComment: () =>
                                      _onCommentPressed(_posts[index]),
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

  // Widget _buildFilterTabs() {
  //   final filters = ['All', 'Following', 'Photos', 'Tips', 'Reviews'];

  //   return Container(
  //     height: 50,
  //     color: Colors.white,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //       itemCount: filters.length,
  //       itemBuilder: (context, index) {
  //         final filter = filters[index];
  //         final isSelected = _selectedFilter == filter;

  //         return Padding(
  //           padding: EdgeInsets.only(right: 8),
  //           child: ChoiceChip(
  //             label: Text(filter),
  //             selected: isSelected,
  //             onSelected: (selected) {
  //               if (selected) _onFilterChanged(filter);
  //             },
  //             checkmarkColor: Colors.white,
  //             backgroundColor: Colors.white,
  //             selectedColor: Colors.teal,
  //             labelStyle: TextStyle(
  //               color: isSelected ? Colors.white : Colors.black87,
  //               fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
  //             ),
  //             shape: StadiumBorder(
  //               side: BorderSide(
  //                 color: isSelected ? Colors.transparent : Colors.grey.shade300,
  //                 width: 1,
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
