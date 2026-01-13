import 'package:flutter/material.dart';
import 'package:she_bloom/screens/healthy_choices_screen.dart';
import '../constants/colors.dart';
import '../widgets/category_card.dart';
import 'package:she_bloom/widgets/info_card.dart';
import 'daily_nutrition_screen.dart';
import 'mood_carousel_card.dart';
import 'profile_screen.dart';
import 'mood_tracker_screen.dart';
import 'hygiene_picks_screen.dart';
import 'workout_yoga_screen.dart';
import 'healthy_choices_screen.dart';
import 'reminder_screen.dart';
import 'period_tracker_screen.dart';
import 'symptom_logger_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // int _selectedIndex = 0 ;
  int _selectedIndex = 0;
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
                    const SizedBox(height: 16),
                    _buildThirdRowCards(),

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
          //Hamburger menu
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),

          const SizedBox(width: 12),

          //User greeting
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

          //Search icon
          IconButton(
            icon: Icon(Icons.search, size: 28, color: AppColors.darkGrey),
            onPressed: () {
              print('Search pressed');
            },
          ),

          const SizedBox(width: 4),

          //Track button
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PeriodTrackerScreen(),
                  ),
              );
            },

            child: Container(
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
          ),
        ],
      ),
    );
  }

  //Top row cards (Daily Nutrition, Healthy Choices)
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DailyNutritionScreen()),
              );
            },
            height: 140,
          ),
        ),

        const SizedBox(width: 16),

        // Healthy Choices card
        Expanded(
          child: CategoryCard(
            title: 'Healthy\nChoices',
            imagePath: 'assets/images/healthyChoices.jpg',
            icon: Icons.favorite,
            backgroundColor: AppColors.primaryPink,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HealthyChoicesScreen())
              );
            },
            height: 140,
          ),
        ),
      ],
    );
  }

  //Bottom row cards (Workout/Yoga, Hygiene Picks)
  Widget _buildBottomRowCards() {
    return Row(
      children: [
        // Workout/Yoga card
        Expanded(
          child: CategoryCard(
            title: 'Workout/\nYoga',
            imagePath: 'assets/images/workoutYoga.jpg',
            icon: Icons.self_improvement,
            backgroundColor: AppColors.coral,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WorkoutYogaScreen()),
              );
            },
            height: 140,
          ),
        ),

        const SizedBox(width: 16),

        //Hygiene Picks card
        Expanded(
          child: CategoryCard(
            title: 'Hygiene\nPicks',
            imagePath: 'assets/images/picks.jpg',
            icon: Icons.cleaning_services,
            backgroundColor: AppColors.burgundy,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HygienePicksScreen()),
              );
            },
            height: 140,
          ),
        ),
      ],
    );
  }

  //carousel and symptom widget
  Widget _buildThirdRowCards() {
    return Row(
      children: [
        Expanded(
          child: MoodCarouselCard(
            title: 'Mood\nTracker',
            backgroundColor: AppColors.burgundy,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoodTrackerScreen(),
                ),
              );
            },
            height: 150,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: CategoryCard(
            title: 'Symptom\nLogger',
            icon: Icons.healing,
            backgroundColor: AppColors.coral,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SymptomLoggerScreen(),
                ),
              );
            },
            height: 150, // keep same height for symmetry
          ),
        ),
      ],
    );
  }


  Widget _buildInfoCards() {
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
          imagePath: 'assets/images/bloodflow.jpg',
          title: 'Pads, Tampons & Blood Flow',
          description: 'Understand pads, tampons and how to track your menstrual blood flow.',
          onTap: () => print('bloodFlow card tapped'),
        ),

        //card3: medication
        InfoCard(
          imagePath: 'assets/images/pills.jpg',
          title: 'Birth Control & Medications',
          description: 'Learn about contraceptive options, pills, patches and how they work.',
          onTap: () => print('medication card tapped'),
        ),

        //card4: breast health
        InfoCard(
          imagePath: 'assets/images/breastCancer.jpg',
          title: 'Breast Health',
          description: 'Everything about breast health, risks and early signs you should know.',
          onTap: () => print('Breast Health card tapped'),
        ),

        //card5: Fertility & Pregnancy
        InfoCard(
          imagePath: 'assets/images/eggs.jpg',
          title: 'Fertility & Pregnancy',
          description: 'Understanding fertility, conception, and pregnancy journey with expert guidance.',
          onTap: () => print('Fertility card tapped'),
        ),

        //card6: pcos/pcod
        InfoCard(
          imagePath: 'assets/images/pcos.png',
          title: 'PCOS/PCOD',
          description: 'Comprehensive guide to managing PCOS symptoms, treatment options, and lifestyle changes.',
          onTap: () => print('PCOS card tapped'),
        ),

        //card7 : mental health
        InfoCard(
          imagePath: 'assets/images/depression.png',
          title: 'Mental Health',
          description: 'Take care of your mental wellbeing with stress management and self-care tips.',
          onTap: () => print('Mental Health card tapped'),
        ),

        //card8: Safe Intimacy Practices
        InfoCard(
          imagePath: 'assets/images/safty.png',
          title: 'Safe Intimacy Practices',
          description: 'Understand condoms, STI prevention, and how to practice safe and healthy sexual activity.',
          onTap: () => print('HPV card tapped'),
        ),

        //card9: pain relife card
        InfoCard(
          imagePath: 'assets/images/cramps.png',
          title: 'Menstrual Cramps & Relief',
          description: 'Understand why cramps happen and explore natural ways to reduce pain.',
          onTap: () => print('HPV card tapped'),
        ),

        //card10: Vaccination card
        InfoCard(
          imagePath: 'assets/images/vaccination.png',
          title: 'HPV & Vaccination',
          description: 'Know how HPV spreads, its risks, and how vaccination protects your health.',
          onTap: () => print('HPV card tapped'),
        ),


        //card11: Ultrasound & check-ups
        InfoCard(
          imagePath: 'assets/images/checkup.png',
          title: 'Health Screenings',
          description: 'Regular health check-ups, ultrasounds, and preventive care for women.',
          onTap: () => print('Screening card tapped'),
        ),

        //card12: Reproductive Health
        InfoCard(
          imagePath: 'assets/images/trackClock.png',
          title: 'Reproductive Health',
          description: 'Understanding reproductive health, contraception, and family planning options.',
          onTap: () => print('Reproductive Health card tapped'),
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

          // Navigate based on index
          if (index == 0) {
            // Already on home, do nothing
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReminderScreen()),
            );
          } else if (index == 2) {
            // TODO: Add track/calendar screen
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PeriodTrackerScreen()),
            );
          }
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
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 28),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 28),
            label: 'Track',
          ),
        ],
      ),
    );
  }
}