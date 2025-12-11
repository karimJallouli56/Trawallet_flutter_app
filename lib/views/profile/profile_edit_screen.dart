import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/appUser.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'package:trawallet_final_version/services/user_service.dart';
import 'package:trawallet_final_version/widgets/input_field.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final AuthService authService = AuthService();
  final UserService userService = UserService();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController travelStoryController = TextEditingController();

  AppUser? appUser;
  bool isLoading = true;
  bool isSaving = false;
  List<String> selectedInterests = [];

  // Available interests
  final List<String> availableInterests = [
    'Adventure',
    'Culture',
    'Food',
    'Nature',
    'Photography',
    'History',
    'Beach',
    'Mountains',
    'City Tours',
    'Wildlife',
    'Sports',
    'Art',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    countryController.dispose();
    bioController.dispose();
    travelStoryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final currentUid = authService.currentUser?.uid;
    if (currentUid == null) return;

    final fetchedUser = await userService.getUserById(currentUid);

    if (fetchedUser != null) {
      setState(() {
        appUser = fetchedUser;
        nameController.text = fetchedUser.name ?? '';
        usernameController.text = fetchedUser.username ?? '';
        phoneController.text = fetchedUser.phone ?? '';
        countryController.text = fetchedUser.country ?? 'Tunisia';
        bioController.text = fetchedUser.bio ?? '';
        travelStoryController.text = fetchedUser.travelStory ?? '';
        selectedInterests = List.from(fetchedUser.interests);
        isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final currentUid = authService.currentUser?.uid;
      if (currentUid == null) return;

      // Update user data
      await userService.updateUser(currentUid, {
        'name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'phone': phoneController.text.trim(),
        'dateOfBirth': dobController.text.trim(),
        'address': addressController.text.trim(),
        'country': countryController.text.trim(),
        'bio': bioController.text.trim(),
        'travelStory': travelStoryController.text.trim(),
        'interests': selectedInterests,
        'hasTravelStory': travelStoryController.text.trim().isNotEmpty,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: appUser?.userAvatar != null
                                ? NetworkImage(appUser!.userAvatar!)
                                : const AssetImage('assets/images/default.png')
                                      as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade600,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Image picker coming soon!'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Personal Information Section
                  _buildSectionTitle(
                    'Personal Information',
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 15),

                  InputField(
                    label: "Full Name",
                    icon: Icons.badge_outlined,
                    controller: nameController,
                    withBorder: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),

                  InputField(
                    label: "Username",
                    icon: Icons.alternate_email,
                    controller: usernameController,
                    withBorder: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),

                  InputField(
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    controller: phoneController,
                    withBorder: true,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: InputField(
                        label: "Date of Birth",
                        icon: Icons.calendar_today_outlined,
                        controller: dobController,
                        withBorder: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  InputField(
                    label: "Address",
                    icon: Icons.location_on,
                    controller: addressController,
                    withBorder: true,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 15),

                  InputField(
                    label: "Country",
                    icon: Icons.flag_outlined,
                    controller: countryController,
                    withBorder: true,
                  ),
                  const SizedBox(height: 15),

                  InputField(
                    label: "Bio",
                    icon: Icons.info_outline,
                    controller: bioController,
                    withBorder: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  // Interests Section
                  _buildSectionTitle('Interests', Icons.favorite_outline),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableInterests.map((interest) {
                        final isSelected = selectedInterests.contains(interest);
                        return GestureDetector(
                          onTap: () => _toggleInterest(interest),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        Colors.teal.shade400,
                                        Colors.teal.shade600,
                                      ],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(color: Colors.grey[300]!),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.teal.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Travel Story Section
                  _buildSectionTitle('Travel Story', Icons.book),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: travelStoryController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            "Share your travel experiences and adventures...",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.teal,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.teal, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
