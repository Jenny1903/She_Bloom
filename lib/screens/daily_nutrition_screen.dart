import 'package:flutter/material.dart';
import '../constants/colors.dart';

class DailyNutritionScreen extends StatelessWidget {
  const DailyNutritionScreen({super.key});

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
          'assets/images/dailyfood.jpg',
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
            'Daily Nutrition',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 20),

          // Nutrition points
          _buildNutritionPoint(
            '1. Calories:',
            '1,800 to 2,400 calories per day, based on age, activity level, and metabolic rate.',
          ),

          _buildNutritionPoint(
            '2. Protein:',
            '46-56 grams daily for tissue repair and immune function.',
          ),

          _buildNutritionPoint(
            '3. Carbohydrates:',
            '130-225 grams daily from whole grains, fruits, and vegetables for energy.',
          ),

          _buildNutritionPoint(
            '4. Fats:',
            'Balance unsaturated fats (avocado, nuts) while limiting saturated and trans fats.',
          ),

          _buildNutritionPoint(
            '5. Fiber:',
            '25 grams daily from vegetables for digestive health.',
          ),

          const SizedBox(height: 20),

          // Vitamins & Minerals section
          Text(
            '6. Vitamins and Minerals:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),

          const SizedBox(height: 12),

          _buildVitaminPoint('Calcium:', '1,000-1,200 milligrams daily for bone health.'),
          _buildVitaminPoint('Iron:', 'Around 18 milligrams daily for oxygen transport (varies based on menstrual status).'),
          _buildVitaminPoint('Vitamin D:', '600-800 IU daily for bone health and immune function.'),
          _buildVitaminPoint('Vitamin B12:', '2.4 micrograms daily for nerve function and red blood cells.'),
          _buildVitaminPoint('Folate:', '400-800 micrograms daily for DNA synthesis (important during pregnancy).'),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  //nutrition point widget
  Widget _buildNutritionPoint(String title, String description) {
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
  Widget _buildVitaminPoint(String title, String description) {
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