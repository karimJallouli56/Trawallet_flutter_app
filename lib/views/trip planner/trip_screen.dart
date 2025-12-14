import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/trip.dart';
import 'package:trawallet_final_version/services/trip_service.dart';
import 'package:trawallet_final_version/views/home/components/navbar.dart';
import 'package:trawallet_final_version/views/trip%20planner/create_trip_screen.dart';
import 'package:trawallet_final_version/views/trip%20planner/details_trip_screen.dart';
import 'package:trawallet_final_version/views/trip%20planner/edit_trip_screen.dart';
import 'package:trawallet_final_version/views/trip%20planner/tripCard.dart';

class TravelSchedulerScreen extends StatefulWidget {
  const TravelSchedulerScreen({super.key});

  @override
  State<TravelSchedulerScreen> createState() => _TravelSchedulerScreenState();
}

class _TravelSchedulerScreenState extends State<TravelSchedulerScreen> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(body: Center(child: Text('Please log in')));
    }

    return Navbar(
      activeScreenId: 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Travel Scheduler',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateTripScreen()),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.teal,
            elevation: 0,
          ),
          body: StreamBuilder<List<Trip>>(
            stream: TripService.getUserTrips(_userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final trips = snapshot.data ?? [];

              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flight_takeoff,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No trips yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start planning your adventure!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  final isCompleted = trip.status == 'completed';

                  return TripCard(
                    trip: trip,
                    onTap: isCompleted
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TripDetailScreen(trip: trip),
                              ),
                            );
                          },

                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditTripScreen(trip: trip),
                        ),
                      );
                    },
                    onDelete: () async {
                      await TripService.deleteTrip(trip.tripId);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
