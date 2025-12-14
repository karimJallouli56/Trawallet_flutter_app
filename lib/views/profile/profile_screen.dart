import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/appUser.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'package:trawallet_final_version/services/user_service.dart';
import 'package:trawallet_final_version/services/favorites_service.dart';
import 'package:trawallet_final_version/views/favorites/favorites_screen.dart';
import 'package:trawallet_final_version/views/home/components/capitalizeWords.dart';
import 'package:trawallet_final_version/views/home/components/navbar.dart';
import 'package:trawallet_final_version/data/mock_destinations.dart';
import 'package:trawallet_final_version/widgets/confirmation_card.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  final UserService userService = UserService();
  final FavoritesService favoritesService = FavoritesService();

  bool isDarkMode = false;
  AppUser? appUser;
  int favoritesCount = 0;
  bool isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavoritesCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
    _loadFavoritesCount();
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

  Future<void> _loadFavoritesCount() async {
    setState(() => isLoadingFavorites = true);
    try {
      await favoritesService.initialize();
      final count = await favoritesService.getFavoritesCount();
      if (mounted) {
        setState(() {
          favoritesCount = count;
          isLoadingFavorites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingFavorites = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await favoritesService.reset();
      await authService.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    } catch (e) {
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

  Future<void> _navigateToFavorites() async {
    final destinations = getMockDestinations();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          allDestinations: destinations,
          onFavoritesChanged: () {
            _loadFavoritesCount();
          },
        ),
      ),
    );
    _loadFavoritesCount();
  }

  @override
  Widget build(BuildContext context) {
    return Navbar(
      activeScreenId: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey[50],
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const Text(
            "Account",
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade400, Colors.teal.shade600],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: appUser?.userAvatar != null
                            ? NetworkImage(appUser!.userAvatar!)
                            : const AssetImage('assets/images/default.png')
                                  as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizeWords(appUser?.name ?? 'User'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${appUser?.username ?? 'username'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildSectionTitle('Account'),
              const SizedBox(height: 10),

              _buildMenuCard([
                _buildMenuItem(
                  Icons.person_outline,
                  "Profile",
                  context,
                  '/profileDetails',
                ),
                _buildDivider(),
                _buildFavoritesMenuItem(),
                _buildDivider(),
                _buildMenuItem(
                  Icons.card_travel,
                  "Travel Career",
                  context,
                  '/travelCareer',
                ),
              ]),

              const SizedBox(height: 20),

              _buildSectionTitle('Preferences'),
              const SizedBox(height: 10),

              _buildMenuCard([
                _buildLanguageItem(),
                _buildDivider(),
                _buildDarkModeToggle(),
              ]),

              const SizedBox(height: 20),

              _buildSectionTitle('More'),
              const SizedBox(height: 10),

              _buildMenuCard([
                _buildMenuItem(
                  Icons.help_outline,
                  "Help & Support",
                  context,
                  '/',
                ),
                _buildDivider(),
                _buildMenuItem(Icons.info_outline, "About", context, '/'),
              ]),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ConfirmationCard.show(
                        context: context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                        confirmText: 'Logout',
                        cancelText: 'Cancel',
                        onConfirm: () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    BuildContext context,
    String route,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.teal, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: () async {
        await Navigator.pushNamed(context, route);
        _loadUserData();
      },
    );
  }

  Widget _buildFavoritesMenuItem() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.favorite_outline, color: Colors.teal, size: 22),
            if (favoritesCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      favoritesCount > 99 ? '99+' : favoritesCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      title: const Text(
        'My Favorites Destinations',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
      onTap: _navigateToFavorites,
    );
  }

  Widget _buildLanguageItem() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(Icons.language, color: Colors.teal, size: 22),
      ),
      title: const Text(
        'Language',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'English (US)',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
      onTap: () {
        // TODO: Implement language selection
      },
    );
  }

  Widget _buildDarkModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.dark_mode_outlined,
              color: Colors.teal,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (val) {
              setState(() {
                isDarkMode = val;
              });
            },
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }
}
