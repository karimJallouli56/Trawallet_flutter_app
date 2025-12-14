import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/appUser.dart';
import 'package:trawallet_final_version/models/destination.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'package:trawallet_final_version/services/destination_service.dart';
import 'package:trawallet_final_version/services/favorites_service.dart';
import 'package:trawallet_final_version/views/destinations/all_destinations_screen.dart';
import 'package:trawallet_final_version/views/home/components/circle_tools.dart';
import 'package:trawallet_final_version/views/home/components/navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DestinationsService _destinationsService = DestinationsService();
  final FavoritesService _favoritesService = FavoritesService();

  List<Destination> _destinations = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = true;
  AppUser? appUser;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _favoritesService.initialize();
    await _loadUserData();
    await _loadData();
  }

  Future<void> _loadUserData() async {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            appUser = AppUser.fromSnapshot(userDoc);
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _destinationsService.fetchDestinations(),
        _favoritesService.getFavorites(),
      ]);

      setState(() {
        _destinations = results[0] as List<Destination>;
        _favoriteIds = results[1] as Set<String>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _toggleFavorite(String destinationId) async {
    setState(() {
      if (_favoriteIds.contains(destinationId)) {
        _favoriteIds.remove(destinationId);
      } else {
        _favoriteIds.add(destinationId);
      }
    });

    final success = await _favoritesService.toggleFavorite(destinationId);

    if (!success) {
      setState(() {
        if (_favoriteIds.contains(destinationId)) {
          _favoriteIds.remove(destinationId);
        } else {
          _favoriteIds.add(destinationId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Navbar(
      activeScreenId: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            color: Colors.teal,
            backgroundColor: Colors.white,
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.teal,
                          backgroundImage:
                              appUser?.userAvatar != null &&
                                  appUser!.userAvatar!.isNotEmpty
                              ? NetworkImage(appUser!.userAvatar!)
                              : null,
                          child:
                              appUser?.userAvatar == null ||
                                  appUser!.userAvatar!.isEmpty
                              ? Text(
                                  appUser?.name.substring(0, 1).toUpperCase() ??
                                      'T',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appUser?.name ?? 'Traveler',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Ready for your next adventure?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.teal.shade400, Colors.teal.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.shade200.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Explorer Level",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      appUser?.rankTitle ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Level ${appUser?.level ?? 0}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              "${appUser?.currentXP ?? 0}",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              " / ${appUser?.xpForNextLevel ?? 0} XP",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: appUser?.progressPercentage ?? 0.0,
                            minHeight: 10,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.amber,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${appUser?.xpNeeded ?? 0} XP to next level!",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Quick Tools",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 110,
                    child: Center(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: [
                          circleTool(
                            context: context,
                            icon: Icons.lock_outline,
                            label: "Vault",
                            color: Colors.teal,
                            route: '/vault',
                          ),
                          circleTool(
                            context: context,
                            icon: Icons.cloud_outlined,
                            label: "Weather",
                            color: Colors.teal,
                            route: '/weather',
                          ),
                          circleTool(
                            context: context,
                            icon: Icons.warning_amber_outlined,
                            label: "SOS",
                            color: Colors.teal,
                            route: '/sos',
                          ),
                          circleTool(
                            context: context,
                            icon: Icons.flight_takeoff_outlined,
                            label: "Flights",
                            color: Colors.teal,
                            route: '/transport',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Best Destinations",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllDestinationsScreen(
                                destinations: _destinations,
                                initialFavoriteIds: _favoriteIds,
                                onRefresh: _loadData,
                                onToggleFavorite: _toggleFavorite,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "View All",
                          style: TextStyle(
                            color: Colors.teal.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _isLoading
                      ? const SizedBox(
                          height: 280,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _destinations.isEmpty
                      ? const SizedBox(
                          height: 280,
                          child: Center(
                            child: Text('No destinations available'),
                          ),
                        )
                      : SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _destinations.take(5).length,
                            itemBuilder: (context, index) {
                              final destination = _destinations[index];
                              final isFavorite = _favoriteIds.contains(
                                destination.id,
                              );
                              return _buildModernDestinationCard(
                                destination: destination,
                                isFavorite: isFavorite,
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDestinationCard({
    required Destination destination,
    required bool isFavorite,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Image.network(
                destination.imageUrl,
                height: 280,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.teal.shade300, Colors.teal.shade600],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 280,
                    width: 200,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  destination.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        destination.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              destination.country,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(destination.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isFavorite
                              ? Colors.teal.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: isFavorite ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.teal : Colors.teal.shade600,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
