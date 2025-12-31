import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String? selectedMood;
  String notes = '';
  DateTime selectedDate = DateTime.now();

  //mood options with emojis and colors
  final List<Map<String, dynamic>> moods = [
    {'emoji': '🥰', 'name': 'Happy', 'color': Color(0xFF4CAF50)},
    {'emoji': '😌', 'name': 'Calm', 'color': Color(0xFF2196F3)},
    {'emoji': '😊', 'name': 'Okay', 'color': Color(0xFF9E9E9E)},
    {'emoji': '😔', 'name': 'Sad', 'color': Color(0xFF607D8B)},
    {'emoji': '😢', 'name': 'Crying', 'color': Color(0xFF5C6BC0)},
    {'emoji': '😡', 'name': 'Angry', 'color': Color(0xFFF44336)},
    {'emoji': '😰', 'name': 'Anxious', 'color': Color(0xFFFF9800)},
    {'emoji': '😴', 'name': 'Tired', 'color': Color(0xFF795548)},
  ];

  void _saveMood() {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Save to Firebase/database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mood saved: $selectedMood'),
        backgroundColor: Colors.green,
      ),
    );

    //clear selection
    setState(() {
      selectedMood = null;
      notes = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood Tracker',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selector
              _buildDateSelector(),
        
              const SizedBox(height: 30),
        
              // "How are you feeling?" header
              Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
        
              const SizedBox(height: 20),
        
              // Mood grid
              _buildMoodGrid(),
        
              const SizedBox(height: 30),
        
              // Notes section
              _buildNotesSection(),
        
              const SizedBox(height: 30),
        
              // Save button
              _buildSaveButton(),
        
              const SizedBox(height: 30),
        
              // Recent mood history
              _buildRecentMoods(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //date selector
  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_getMonthName(selectedDate.month)} ${selectedDate.day}, ${selectedDate.year}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: AppColors.darkPink),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  //mood grid
  Widget _buildMoodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isSelected = selectedMood == mood['name'];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedMood = mood['name'];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? mood['color'].withOpacity(0.2)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? mood['color']
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mood['emoji'],
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  mood['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? mood['color'] : AppColors.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //notes section
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a note (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          onChanged: (value) {
            notes = value;
          },
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            hintStyle: TextStyle(color: AppColors.textLight),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  //save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveMood,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Mood',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  //recent moods
  Widget _buildRecentMoods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show full history
              },
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppColors.darkPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        //weekly mood chart
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.lightPink.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMoodBar('Mon', '😊', 0.8),
              _buildMoodBar('Tue', '😌', 0.6),
              _buildMoodBar('Wed', '😐', 0.4),
              _buildMoodBar('Thu', '😡', 0.9),
              _buildMoodBar('Fri', '😔', 0.3),
              _buildMoodBar('Sat', '🥰', 0.85),
              _buildMoodBar('Sun', '😌', 0.7),
            ],
          ),
        ),
      ],
    );
  }

  //mood bar for chart
  Widget _buildMoodBar(String day, String emoji, double height) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Container(
            width: 30,
            height: 55 * height,
            decoration: BoxDecoration(
              color: AppColors.darkPink,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  //helper: to get month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

