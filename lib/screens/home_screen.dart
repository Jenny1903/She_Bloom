import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/category_card.dart';
import 'package:she_bloom/widgets/info_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0 ;
  String userName = "Emily";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //grid
                      _buildTopRowCards(),
                      const SizedBox(height: 16),
                      _buildBottomRowCards(),

                      const SizedBox(height: 24),

                      //learn more
                      Text(
                        'Learn more about your body',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      // _buildLearnMoreSection(),

                      const SizedBox(height: 20),

                      _buildInfoCards(),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hamburger menu
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () {
              print('Menu pressed');
            },
          ),

          const SizedBox(width: 12),

          // User greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryPink,
                      child: Text(
                        userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search icon
          IconButton(
            icon: Icon(Icons.search, size: 28, color: AppColors.darkGrey),
            onPressed: () {
              print('Search pressed');
            },
          ),

          const SizedBox(width: 4),

          // Track button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.darkPink, width: 1),
            ),
            child: Text(
              'Track',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkPink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Top row cards (Daily Nutrition, Healthy Choices)
  Widget _buildTopRowCards() {
    return Row(
      children: [
        // Daily Nutrition card
        Expanded(
          child: CategoryCard(
            title: 'Daily\nNutrition',
            imagePath: 'assets/images/dailyfood.jpg',
            icon: Icons.restaurant,
            backgroundColor: AppColors.coral,
            onTap: () {
              print('Daily Nutrition tapped');
            },
            height: 140,
          ),
        ),

        const SizedBox(width: 16),

        // Healthy Choices card
        Expanded(
          child: CategoryCard(
            title: 'Healthy\nChoices',
            icon: Icons.favorite,
            backgroundColor: AppColors.primaryPink,
            onTap: () {
              print('Healthy Choices tapped');
            },
            height: 140,
          ),
        ),
      ],
    );
  }

  // Bottom row cards (Workout/Yoga, Hygiene Picks)
  Widget _buildBottomRowCards() {
    return Row(
      children: [
        // Workout/Yoga card
        Expanded(
          child: CategoryCard(
            title: 'Workout/\nYoga',
            icon: Icons.self_improvement,
            backgroundColor: AppColors.coral,
            onTap: () {
              print('Workout/Yoga tapped');
            },
            height: 140,
          ),
        ),

        const SizedBox(width: 16),

        // Hygiene Picks card
        Expanded(
          child: CategoryCard(
            title: 'Hygiene\nPicks',
            imagePath: 'assets/images/picks.jpg',
            icon: Icons.cleaning_services,
            backgroundColor: AppColors.burgundy,
            onTap: () {
              print('Hygiene Picks tapped');
            },
            height: 140,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(){
    return Column(
      children: [
        //Card1: menstruation
        InfoCard(
            imagePath: 'assets/images/menstruation.jpg',
            title: 'Menstruation',
            description: 'Learn about your menstrual cycle, track your period, and understand your body better.',
            onTap: () => print('Menstruation card tapped'),
        ),

        //card2: bloodFlow
        InfoCard(
          imagePath: 'assets/bloodflow.jpg',
          title: 'Women\'s Health',
          description: 'Essential information about women\'s health, wellness tips, and lifestyle guidance.',
          onTap: () => print('Women\'s Health card tapped'),
        ),

      ],
    );
  }


  //Bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          print('Bottom nav item $index tapped');
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.darkPink,
        unselectedItemColor: AppColors.mediumGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline, size: 28),
            label: 'Check',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit, size: 28),
            label: 'Edit',
          ),
        ],
      ),
    );
  }

}
