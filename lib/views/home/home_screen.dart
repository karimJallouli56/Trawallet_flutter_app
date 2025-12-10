import 'package:flutter/material.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'package:trawallet_final_version/views/home/components/circle_tools.dart';
import 'package:trawallet_final_version/views/home/components/destination_card.dart';
import 'package:trawallet_final_version/views/home/components/navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Home'),
    //       actions: [
    //         IconButton(
    //           icon: const Icon(Icons.logout),
    //           onPressed: () async {
    //             final confirmed = await showDialog<bool>(
    //               context: context,
    //               builder: (context) => AlertDialog(
    //                 title: const Text('Sign Out'),
    //                 content: const Text('Are you sure you want to sign out?'),
    //                 actions: [
    //                   TextButton(
    //                     onPressed: () => Navigator.pop(context, false),
    //                     child: const Text('Cancel'),
    //                   ),
    //                   TextButton(
    //                     onPressed: () => Navigator.pop(context, true),
    //                     child: const Text('Sign Out'),
    //                   ),
    //                 ],
    //               ),
    //             );
    //             if (confirmed == true) {
    //               await authService.signOut();
    //             }
    //           },
    //           tooltip: 'Sign Out',
    //         ),
    //       ],
    //     ),
    //     body: Center(
    //       child: Padding(
    //         padding: const EdgeInsets.all(24.0),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             const Icon(
    //               Icons.check_circle_outline,
    //               size: 100,
    //               color: Colors.green,
    //             ),
    //             const SizedBox(height: 24),
    //             const Text(
    //               'Welcome!',
    //               style: TextStyle(
    //                 fontSize: 32,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //             const SizedBox(height: 16),
    //             Text(
    //               'You are signed in as:',
    //               style: TextStyle(
    //                 fontSize: 16,
    //                 color: Colors.grey[600],
    //               ),
    //             ),
    //             const SizedBox(height: 8),
    //             Text(
    //               user?.email ?? 'Unknown',
    //               style: const TextStyle(
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.w500,
    //               ),
    //             ),
    //             const SizedBox(height: 32),
    //             Card(
    //               child: Padding(
    //                 padding: const EdgeInsets.all(16.0),
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     const Text(
    //                       'User Information',
    //                       style: TextStyle(
    //                         fontSize: 18,
    //                         fontWeight: FontWeight.bold,
    //                       ),
    //                     ),
    //                     const Divider(),
    //                     const SizedBox(height: 8),
    //                     _buildInfoRow('Email', user?.email ?? 'N/A'),
    //                     const SizedBox(height: 8),
    //                     _buildInfoRow('User ID', user?.uid ?? 'N/A'),
    //                     const SizedBox(height: 8),
    //                     _buildInfoRow(
    //                       'Email Verified',
    //                       user?.emailVerified == true ? 'Yes' : 'No',
    //                     ),
    //                     const SizedBox(height: 8),
    //                     _buildInfoRow(
    //                       'Provider',
    //                       user?.providerData.isNotEmpty == true
    //                           ? user!.providerData.first.providerId
    //                           : 'N/A',
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    return Navbar(
      activeScreenId: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                const Text(
                  "Hello,",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Text(
                  user!.email ?? 'e',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // ================= SEARCH BAR =================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Search destinations or tools...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= FEATURE CIRCLES =================
                const Text(
                  "Quick Tools",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      circleTool(
                        context: context,
                        icon: Icons.lock_outline,
                        label: "Vault",
                        color: Colors.blue,
                        route: '/vault',
                      ),
                      circleTool(
                        context: context,
                        icon: Icons.cloud_outlined,
                        label: "Weather",
                        color: Colors.orange,
                        route: '/weather',
                      ),
                      circleTool(
                        context: context,
                        icon: Icons.calendar_month_outlined,
                        label: "Planner",
                        color: Colors.green,
                      ),
                      circleTool(
                        context: context,
                        icon: Icons.warning_amber_outlined,
                        label: "SOS",
                        color: Colors.red,
                        route: '/sos',
                      ),
                      circleTool(
                        context: context,
                        icon: Icons.flight_takeoff_outlined,
                        label: "Flights",
                        color: Colors.purple,
                        route: '/transport',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // ================= BEST DESTINATIONS =================
                Text(
                  "Best Destinations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 15),

                SizedBox(
                  height: 230,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      DestinationCard(
                        title: "Paris",
                        country: "France",
                        image: "assets/images/paris.jpg",
                      ),
                      DestinationCard(
                        title: "Tokyo",
                        country: "Japan",
                        image: "assets/images/kyoto.jpg",
                      ),
                      DestinationCard(
                        title: "New York",
                        country: "USA",
                        image: "assets/images/kyoto.jpg",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }
}
