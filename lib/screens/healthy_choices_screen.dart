import 'package:flutter/material.dart';
import '../constants/colors.dart';

class HealthyChoicesScreen extends StatelessWidget {
  const HealthyChoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            _buildAppBar(context),

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
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        child: Image.asset(
          'assets/images/healthy_choices.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
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
                  Icons.favorite,
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
            'Healthy Choices',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 20),

          _buildChoicePoint(
            '1. Balanced Diet:',
            'Choose meals rich in fruits, vegetables, whole grains, and lean proteins.',
          ),

          _buildChoicePoint(
            '2. Stay Hydrated:',
            'Drink at least 8 glasses of water daily to support body functions.',
          ),

          _buildChoicePoint(
            '3. Limit Sugar:',
            'Reduce intake of sugary snacks and beverages to maintain energy levels.',
          ),

          _buildChoicePoint(
            '4. Active Lifestyle:',
            'Incorporate physical activity into daily routines for better health.',
          ),

          _buildChoicePoint(
            '5. Mindful Eating:',
            'Pay attention to portion sizes and hunger cues to avoid overeating.',
          ),

          const SizedBox(height: 20),

          // Lifestyle habits section
          Text(
            '6. Healthy Lifestyle Habits:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 12),

          _buildBulletPoint('Adequate Sleep:', 'Aim for 7–9 hours of sleep every night.'),
          _buildBulletPoint('Stress Management:', 'Practice meditation or deep breathing to relax.'),
          _buildBulletPoint('Avoid Smoking:', 'Stay away from tobacco products for better lung health.'),
          _buildBulletPoint('Limit Alcohol:', 'Consume alcohol in moderation or avoid it completely.'),
          _buildBulletPoint('Regular Checkups:', 'Visit healthcare providers for routine health screenings.'),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  //choice point widget
  Widget _buildChoicePoint(String title, String description) {
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

  //bullet point widget
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