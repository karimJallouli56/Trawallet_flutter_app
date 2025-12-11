import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:trawallet_final_version/models/trip.dart';
import 'package:trawallet_final_version/models/activity.dart';
import 'package:trawallet_final_version/services/trip_service.dart';

class TravelCareerScreen extends StatefulWidget {
  const TravelCareerScreen({Key? key}) : super(key: key);

  @override
  State<TravelCareerScreen> createState() => _TravelCareerScreenState();
}

class _TravelCareerScreenState extends State<TravelCareerScreen> {
  bool _isLoading = true;
  List<Trip> _completedTrips = [];
  Map<String, List<Activity>> _tripActivities = {};
  Set<String> _expandedTripIds = {}; // Track which trips are expanded

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final trips = await TripService.getCompletedTrips(userId);

      // Load activities for each trip
      final activities = <String, List<Activity>>{};
      for (var trip in trips) {
        final tripActivities = await ActivityService.getTripActivities(
          trip.tripId,
        ).first;
        activities[trip.tripId] = tripActivities;
      }

      setState(() {
        _completedTrips = trips;
        _tripActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading roadmap: $e')));
      }
    }
  }

  void _toggleTripExpansion(String tripId) {
    setState(() {
      if (_expandedTripIds.contains(tripId)) {
        _expandedTripIds.remove(tripId);
      } else {
        _expandedTripIds.add(tripId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
        title: const Text(
          'My Travel Roadmap',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _completedTrips.isEmpty
          ? _buildEmptyState()
          : _buildRoadmap(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined, size: 100, color: Colors.grey[700]),
          const SizedBox(height: 24),
          Text(
            'No completed trips yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your journey and create memories!',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmap() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.teal,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: _completedTrips.length,
        itemBuilder: (context, index) {
          final trip = _completedTrips[index];
          final activities = _tripActivities[trip.tripId] ?? [];

          return _buildTripSection(trip, activities);
        },
      ),
    );
  }

  Widget _buildTripSection(Trip trip, List<Activity> activities) {
    final completedActivities = activities.where((a) => a.isCompleted).length;
    final totalActivities = activities.length;
    final isExpanded = _expandedTripIds.contains(trip.tripId);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Header - Now clickable
          GestureDetector(
            onTap: () => _toggleTripExpansion(trip.tripId),
            child: _buildTripHeader(
              trip,
              completedActivities,
              totalActivities,
              isExpanded,
            ),
          ),
          // Activities Roadmap - Shows only when expanded
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: activities.isNotEmpty
                  ? _buildActivitiesRoadmap(activities)
                  : _buildNoActivities(),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHeader(
    Trip trip,
    int completedActivities,
    int totalActivities,
    bool isExpanded,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isExpanded
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.teal,
                  Colors.teal.shade400,
                  Colors.teal.shade600,
                ],
              )
            : null,
        color: isExpanded ? null : Colors.grey.shade50,
        border: isExpanded
            ? null
            : Border.all(color: Colors.teal.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),

            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flight_takeoff,
                color: isExpanded ? Colors.white : Colors.teal,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trip.destination,
                  style: TextStyle(
                    color: isExpanded ? Colors.white : Colors.teal,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: isExpanded ? Colors.white : Colors.teal,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isExpanded ? Colors.white70 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}',
                style: TextStyle(
                  color: isExpanded ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: isExpanded ? Colors.white70 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                '$completedActivities/$totalActivities activities completed',
                style: TextStyle(
                  color: isExpanded ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isExpanded ? 'Tap to hide activities' : 'Tap to view activities',
            style: TextStyle(
              color: isExpanded
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey.shade500,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActivities() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'No activities for this trip',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildActivitiesRoadmap(List<Activity> activities) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isLast = index == activities.length - 1;
        return _buildActivityNode(activity, isLast);
      },
    );
  }

  Widget _buildActivityNode(Activity activity, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          SizedBox(
            width: 50,
            child: Column(
              children: [
                // Node
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activity.isCompleted ? Colors.teal : Colors.white,
                    border: Border.all(
                      color: activity.isCompleted
                          ? Colors.teal
                          : Colors.teal.shade200,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    activity.isCompleted ? Icons.check : Icons.circle,
                    color: activity.isCompleted ? Colors.white : Colors.teal,
                    size: activity.isCompleted ? 24 : 12,
                  ),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.teal.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Activity Card
          Expanded(
            child: GestureDetector(
              onLongPress: () => _showActivityDetails(activity),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activity.isCompleted
                        ? Colors.teal.withOpacity(0.3)
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (activity.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.teal,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat(
                            'MMM d, yyyy • HH:mm',
                          ).format(activity.dateTime),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (activity.location != null &&
                        activity.location!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              activity.location!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(Activity activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => _buildActivityDetailsSheet(activity),
    );
  }

  Widget _buildActivityDetailsSheet(Activity activity) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: activity.isCompleted
                            ? Colors.teal
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activity.isCompleted
                            ? Icons.check_circle
                            : Icons.pending_actions,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: activity.isCompleted
                                  ? Colors.teal
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              activity.isCompleted
                                  ? 'Completed'
                                  : 'Not Completed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  Icons.calendar_today,
                  'Date & Time',
                  DateFormat('EEEE, MMMM d, yyyy').format(activity.dateTime),
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'Time',
                  DateFormat('HH:mm').format(activity.dateTime),
                ),
                if (activity.location != null && activity.location!.isNotEmpty)
                  _buildDetailRow(
                    Icons.location_on,
                    'Location',
                    activity.location!,
                  ),

                if (activity.category.isNotEmpty)
                  _buildDetailRow(
                    Icons.category,
                    'Category',
                    activity.category,
                  ),
                if (activity.description != null &&
                    activity.description!.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.description,
                    'Description',
                    activity.description!,
                  ),
                ],
                const SizedBox(height: 20),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
