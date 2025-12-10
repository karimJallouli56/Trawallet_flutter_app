import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/appUser.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'package:trawallet_final_version/services/user_service.dart';
import 'package:trawallet_final_version/views/home/components/capitalizeWords.dart';
import 'package:trawallet_final_version/views/home/components/navbar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  final UserService userService = UserService();
  bool isDarkMode = false;

  AppUser? appUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Add this to reload data when screen becomes visible again
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data whenever we return to this screen
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUid = authService.currentUser?.uid;

    if (currentUid == null) return;

    final fetchedUser = await userService.getUserById(currentUid);

    if (mounted) {
      setState(() {
        appUser = fetchedUser;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await authService.signOut();
      // Navigate to root and remove all previous routes
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    } catch (e) {
      // Show error message if logout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Navbar(
      activeScreenId: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ================= PROFILE HEADER =================
              Row(
                children: [
                  // Photo
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/images/default.png'),
                  ),
                  const SizedBox(width: 15),

                  // Name + phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capitalizeWords(appUser?.name ?? 'User'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'tunisie',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ================= SETTINGS LIST =================
              _buildTile(
                Icons.favorite_border,
                "My Favorite Destinations",
                context,
                '/profileDetails',
              ),
              _buildTile(
                Icons.person_outline,
                "Profile",
                context,
                '/profileDetails',
              ),
              _buildTile(
                Icons.card_travel,
                "Travel Career",
                context,
                '/travelCareer',
              ),
              _buildTileWithValue(Icons.language, "Language", "English (US)"),
              _buildToggleTile(Icons.dark_mode_outlined, "Dark Mode"),

              const SizedBox(height: 10),
              // Logout
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  "Logout",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                onTap: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleLogout();
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Reusable Settings Tiles =================

  Widget _buildTile(
    IconData icon,
    String title,
    BuildContext context,
    String route,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        // Navigate and wait for the page to close
        await Navigator.pushNamed(context, route);
        // Reload data when we come back
        _loadUserData();
      },
    );
  }

  Widget _buildTileWithValue(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildToggleTile(IconData icon, String title) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: isDarkMode,
      onChanged: (val) {
        setState(() {
          isDarkMode = val;
        });
      },
    );
  }
}
