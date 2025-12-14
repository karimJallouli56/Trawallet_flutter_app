import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/destination.dart';

class AllDestinationsScreen extends StatefulWidget {
  final List<Destination> destinations;
  final Set<String> initialFavoriteIds;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String) onToggleFavorite;

  const AllDestinationsScreen({
    super.key,
    required this.destinations,
    required this.initialFavoriteIds,
    required this.onRefresh,
    required this.onToggleFavorite,
  });

  @override
  State<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends State<AllDestinationsScreen> {
  late Set<String> _favoriteIds;

  @override
  void initState() {
    super.initState();
    _favoriteIds = Set.from(widget.initialFavoriteIds);
  }

  Future<void> _handleToggleFavorite(String destinationId) async {
    // Optimistically update UI
    setState(() {
      if (_favoriteIds.contains(destinationId)) {
        _favoriteIds.remove(destinationId);
      } else {
        _favoriteIds.add(destinationId);
      }
    });

    // Call parent's toggle function
    await widget.onToggleFavorite(destinationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'All Destinations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: widget.destinations.isEmpty
              ? const Center(child: Text('No destinations available'))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: widget.destinations.length,
                  itemBuilder: (context, index) {
                    final destination = widget.destinations[index];
                    final isFavorite = _favoriteIds.contains(destination.id);
                    return _buildDestinationGridCard(
                      context: context,
                      destination: destination,
                      isFavorite: isFavorite,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildDestinationGridCard({
    required BuildContext context,
    required Destination destination,
    required bool isFavorite,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.network(
              destination.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
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
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.country,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
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
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _handleToggleFavorite(destination.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.teal : Colors.teal.shade600,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
