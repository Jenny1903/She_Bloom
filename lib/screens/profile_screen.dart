import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //to Load user data from Firestore
  Future<void> _loadUserData() async {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      Map<String, dynamic>? data = await _authService.getUserData(userId);
      setState(() {
        userData = data;
        isLoading = false;
      });
    }
  }

  //to Show logout bottom sheet
  void _showLogoutSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => _buildLogoutSheet(),
    );
  }

  //to Logout bottom sheet content
  Widget _buildLogoutSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout,
              size: 40,
              color: AppColors.darkPink,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Log Out',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            'Are you sure you want to log out?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMedium,
            ),
          ),

          const SizedBox(height: 32),

          // Logout button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close bottom sheet
                await _authService.signOut();

                // Navigate to login screen
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B9FED), // Blue background
      body: SafeArea(
        bottom: false, // Allow content to go to bottom edge
        child: Column(
          children: [
            // Top section with profile
            _buildTopSection(),

            // Bottom white section with menu items
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildMenuItem(
                      icon: Icons.security,
                      title: 'Security x Settings',
                      subtitle: 'Password and PIN',
                      onTap: () => print('Security tapped'),
                    ),
                    _buildMenuItem(
                      icon: Icons.subscriptions,
                      title: 'Subscriptions',
                      subtitle: 'Spotify, Glo',
                      onTap: () => print('Subscriptions tapped'),
                    ),
                    _buildMenuItem(
                      icon: Icons.description,
                      title: 'Terms and Conditions',
                      subtitle: 'Agreements',
                      onTap: () => print('Terms tapped'),
                    ),

                    const SizedBox(height: 20),

                    // Logout button
                    _buildLogoutButton(),

                    const Spacer(),

                    // Bottom navigation
                    _buildBottomNav(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top section with profile info
  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header with back and edit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 24),
                onPressed: () => print('Edit profile'),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Profile picture with online indicator
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primaryPink,
                  ),
                ),
              ),

              // Online indicator
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User name
          Text(
            isLoading ? 'Loading...' : (userData?['name'] ?? 'User'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Rating stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '5.0 ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ...List.generate(5, (index) => const Icon(
                Icons.star,
                color: Colors.amber,
                size: 18,
              )),
            ],
          ),
        ],
      ),
    );
  }

  //Menu item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.lightPink.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.darkPink,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: AppColors.mediumGrey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  //Logout button
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _showLogoutSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  //Bottom navigation
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 20, // Extra padding for iPhone home indicator
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(Icons.home_outlined, false, 'Home'),
          _buildNavIcon(Icons.calendar_today_outlined, false, 'Calendar'),
          _buildNavIcon(Icons.swap_horiz, false, 'Activity'),
          _buildNavIcon(Icons.person, true, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.darkPink.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 26,
            color: isActive ? AppColors.darkPink : AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}
