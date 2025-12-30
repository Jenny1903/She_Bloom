import 'package:flutter/material.dart';
import '../constants/colors.dart';

class HygienePicksScreen extends StatelessWidget {
  const HygienePicksScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button
            _buildAppBar(context),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Image
                    _buildHeaderImage(),

                    // Content
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  //app bar with back button
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  //header image
  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity,
      height: 250,
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/picks.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Placeholder if image not found
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.coral,
                    AppColors.primaryPink,
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //content section
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Hygiene Picks',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 20),

          // hygiene points
          _buildHygienePicks(
            '1. Hand Hygiene:',
            'Wash hands regularly with soap for at least 20 seconds to prevent infections.',
          ),

          _buildHygienePicks(
            '2. Oral Care:',
            'Brush twice daily and floss once to maintain dental and gum health.',
          ),

          _buildHygienePicks(
            '3. Bathing:',
            'Shower daily to remove sweat, bacteria, and dead skin cells.',
          ),

          _buildHygienePicks(
            '4. Clean Clothing:',
            'Wear clean clothes and change undergarments daily to avoid skin issues.',
          ),

          _buildHygienePicks(
            '5. Nail Care:',
            'Keep nails trimmed and clean to prevent bacterial buildup.',
          ),

          const SizedBox(height: 20),

          // Personal Care Essentials
          Text(
            '6. Personal Care Essentials:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 12),

          _buildBulletPoint('Face Wash:', 'Use a gentle cleanser twice daily for clear skin.'),
          _buildBulletPoint('Deodorant:', 'Apply daily to control body odor.'),
          _buildBulletPoint('Hair Care:', 'Wash hair 2–3 times a week depending on scalp type.'),
          _buildBulletPoint('Sanitary Hygiene:', 'Use clean and safe menstrual products and maintain proper disposal.'),
          _buildBulletPoint('Foot Care:', 'Wash and dry feet properly to prevent fungal infections.'),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  //nutrition point widget
  Widget _buildHygienePicks(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  //vitamin point widget
  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  TextSpan(
                    text: ' $description',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //bottom navigation
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavIcon(Icons.check_circle_outline, false),
          _buildNavIcon(Icons.home, true),
          _buildNavIcon(Icons.edit_outlined, false),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive) {
    return Icon(
      icon,
      size: 28,
      color: isActive ? AppColors.darkPink : AppColors.mediumGrey,
    );
  }
}