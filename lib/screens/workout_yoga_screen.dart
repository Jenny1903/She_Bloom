import 'package:flutter/material.dart';
import '../constants/colors.dart';

class WorkoutYogaScreen extends StatelessWidget {
  const WorkoutYogaScreen({super.key});

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

      // Bottom navigation
      bottomNavigationBar: _buildBottomNav(context),
    );
  }


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
          'assets/images/workout_yoga.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPink,
                    AppColors.coral,
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.self_improvement,
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
            'Workout & Yoga',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 20),

          _buildWorkoutPoint(
            '1. Daily Movement:',
            'Engage in at least 30 minutes of physical activity to keep your body active.',
          ),

          _buildWorkoutPoint(
            '2. Strength Training:',
            'Include strength exercises 2–3 times a week to build muscle and bone strength.',
          ),

          _buildWorkoutPoint(
            '3. Cardio Exercises:',
            'Walking, cycling, or running improves heart health and stamina.',
          ),

          _buildWorkoutPoint(
            '4. Yoga Practice:',
            'Yoga improves flexibility, posture, balance, and mental focus.',
          ),

          _buildWorkoutPoint(
            '5. Stretching:',
            'Stretch before and after workouts to prevent injuries and muscle stiffness.',
          ),

          const SizedBox(height: 20),

          //yoga poses section
          Text(
            '6. Recommended Yoga Poses:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 12),

          _buildBulletPoint('Surya Namaskar:', 'A full-body flow improving flexibility and strength.'),
          _buildBulletPoint('Tadasana:', 'Improves posture and balance.'),
          _buildBulletPoint('Bhujangasana:', 'Strengthens the spine and relieves back pain.'),
          _buildBulletPoint('Vrikshasana:', 'Enhances balance and concentration.'),
          _buildBulletPoint('Shavasana:', 'Relaxes the body and reduces stress after workouts.'),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  //workout point widget
  Widget _buildWorkoutPoint(String title, String description) {
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