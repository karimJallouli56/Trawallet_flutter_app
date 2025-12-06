import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/appUser.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'package:trawallet_final_version/services/user_service.dart';
import 'package:trawallet_final_version/views/home/components/capitalizeWords.dart';

class ProfileDetailsScreen extends StatefulWidget {
  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final AuthService authService = AuthService();
  final UserService userService = UserService();
  AppUser? appUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUid = authService.currentUser?.uid;
    if (currentUid == null) return;

    final fetchedUser = await userService.getUserById(currentUid);
    setState(() {
      appUser = fetchedUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.teal),
            onPressed: () async {
              // Wait for result from edit page
              final result = await Navigator.pushNamed(context, '/profileEdit');
              // If edit was successful, reload data
              if (result == true) {
                _loadUserData();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(
                          'assets/images/default.png',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // User Name
                  Text(
                    capitalizeWords(appUser?.name ?? 'User'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Email
                  Text(
                    user?.email ?? 'No email',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  // Information Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildInfoCard("Personal Information", [
                          _buildInfoRow(
                            Icons.person,
                            "Full Name",
                            appUser?.name ?? 'Not set',
                          ),
                          _buildInfoRow(
                            Icons.email,
                            "Email",
                            user?.email ?? 'Not set',
                          ),
                          _buildInfoRow(
                            Icons.phone,
                            "Phone",
                            appUser?.phone ?? 'Not set',
                          ),
                        ]),

                        const SizedBox(height: 20),

                        _buildInfoCard("Additional Information", [
                          _buildInfoRow(
                            Icons.flag,
                            "Country",
                            appUser?.country ?? 'Tunisia',
                          ),
                        ]),

                        const SizedBox(height: 30),

                        // Edit Profile Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Wait for result from edit page
                              final result = await Navigator.pushNamed(
                                context,
                                '/profileEdit',
                              );
                              // If edit was successful, reload data
                              if (result == true) {
                                _loadUserData();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
