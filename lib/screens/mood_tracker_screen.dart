import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'dart:ui';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String? selectedMood;
  String notes = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  //mood options with emojis and colors
  final List<Map<String, dynamic>> moods = [
    {
      'name': 'Very Pleasant',
      'emoji': '😊',
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFFB6B9)],
      'bgColor': Color(0xFFFFE5E5),
    },
    {
      'name': 'Pleasant',
      'emoji': '🙂',
      'gradient': [Color(0xFFFFA726), Color(0xFFFFD54F)], // Orange/Yellow
      'bgColor': Color(0xFFFFF3E0),
    },
    {
      'name': 'Neutral',
      'emoji': '😐',
      'gradient': [Color(0xFF42A5F5), Color(0xFF90CAF9)], // Blue
      'bgColor': Color(0xFFE3F2FD),
    },
    {
      'name': 'Unpleasant',
      'emoji': '😕',
      'gradient': [Color(0xFF7E57C2), Color(0xFFB39DDB)], // Purple
      'bgColor': Color(0xFFF3E5F5),
    },
    {
      'name': 'Very Unpleasant',
      'emoji': '😢',
      'gradient': [Color(0xFF5C6BC0), Color(0xFF9FA8DA)], // Indigo
      'bgColor': Color(0xFFE8EAF6),
    },
    {
      'name': 'Calm',
      'emoji': '😌',
      'gradient': [Color(0xFF26A69A), Color(0xFF80CBC4)], // Teal
      'bgColor': Color(0xFFE0F2F1),
    },
  ];

  @override
  void initState(){
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void disposse(){
    _animationController.dispose();
    super.dispose();
  }

  void _selectMood(String moodName){
    setState(() {
      if (selectedMood == moodName) {
        selectedMood = null;
        _animationController.reverse();
      } else {
        selectedMood = moodName;
        _animationController.forward();
      }
    });
  }

  void _saveMood() {
      if (selectedMood == null) {
        _showMessage('Please select how you\'re feeling', isError: true);
        return;
      }

      // TODO: Save to Firebase
      _showMessage('Mood logged successfully! ✨', isError: false);

      setState(() {
        selectedMood = null;
        notes = '';
        _animationController.reverse();
      });
    }

    void _showMessage(String message, {required bool isError}){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message),
          backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
      );
    }

 @override
 Widget build (BuildContext context) {
   return Scaffold(
     body: Container(
       decoration: BoxDecoration(
         gradient: LinearGradient(
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
           colors: [
             Color(0xFFF8BBD0), // Light Pink
             Color(0xFFE1BEE7), // Light Purple
             Color(0xFFB2DFDB), // Light Teal
           ],
         ),
       ),
       child: SafeArea(
         child: Column(
           children: [
             _buildAppBar(),
             Expanded(
               child: SingleChildScrollView(
                 physics: const BouncingScrollPhysics(),
                 padding: const EdgeInsets.all(20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildHeader(),
                     const SizedBox(height: 24),
                     _buildDateCard(),
                     const SizedBox(height: 32),
                     _buildMoodBubbles(),
                     const SizedBox(height: 32),
                     if (selectedMood != null) ...[
                       _buildNotesCard(),
                       const SizedBox(height: 24),
                       _buildSaveButton(),
                       const SizedBox(height: 32),
                     ],
                     _buildWeeklyChart(),
                     const SizedBox(height: 20),
                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }

 //appBar
 Widget _buildAppBar(){
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 24),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              padding: const EdgeInsets.all(12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
 }

 //header
 Widget _buildHeader(){
    return const Text(
      'How are you\nfeeling today?',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.2,
      ),
    );
 }

 //date card
  Widget _buildDateCard(){
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //mood bubbles with expnad animation
  Widget _buildMoodBubbles(){
    return Column(
      children: moods.map((mood) {
        bool isSelected = selectedMood == mood['name'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMoodBubble(mood, isSelected),
        );
      }).toList(),
    );
  }

  //mood bar for chart
  Widget _buildMoodBubble(Map<String, dynamic> mood, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectMood(mood['name'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isSelected ? 160 : 80,
        decoration: BoxDecoration(
          color: mood['bgColor'],
          borderRadius: BorderRadius.circular(isSelected ? 30 : 40),
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: (mood['gradient'][0] as Color).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
              : [],
        ),
        child: Stack(
          children: [
            // Gradient overlay when selected
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (mood['gradient'][0] as Color).withOpacity(0.2),
                        (mood['gradient'][1] as Color).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: isSelected
                  ? _buildExpandedMoodContent(mood)
                  : _buildCollapsedMoodContent(mood),
            ),
          ],
        ),
      ),
    );

  }

  //collapsed bubble content
  Widget _buildCollapsedMoodContent(Map<String, dynamic> mood){
    return Row(
      children: [
        //Emoji circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: mood['gradient'] as List<Color>,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (mood['gradient'][0] as Color).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              mood['emoji'] as String,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),

        const SizedBox(width: 16),
        //mood name
        Expanded(
          child: Text(
            mood['name'] as String,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  //expanded bubble content
  Widget _buildExpandedMoodContent(Map<String, dynamic> mood){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large emoji
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: mood['gradient'] as List<Color>,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (mood['gradient'][0] as Color).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              mood['emoji'] as String,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Mood name
        Text(
          mood['name'] as String,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  //notes card
  Widget _buildNotesCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_note, size: 20, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'What\'s on your mind?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 3,
                  onChanged: (value) => notes = value,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts... (optional)',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //save button
  Widget _buildSaveButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _saveMood,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFE91E63).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Text(
            'Save Mood',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  //weekly mood chart
  Widget _buildWeeklyChart() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'This Week\'s Mood',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Chart bars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMoodBar('Mon', '😊', 0.8, Color(0xFFFF6B6B)),
                  _buildMoodBar('Tue', '😌', 0.6, Color(0xFF26A69A)),
                  _buildMoodBar('Wed', '😐', 0.4, Color(0xFF42A5F5)),
                  _buildMoodBar('Thu', '😕', 0.7, Color(0xFF7E57C2)),
                  _buildMoodBar('Fri', '😢', 0.3, Color(0xFF5C6BC0)),
                  _buildMoodBar('Sat', '🙂', 0.85, Color(0xFFFFA726)),
                  _buildMoodBar('Sun', '😊', 0.9, Color(0xFFFF6B6B)),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '🌟 Your mood is getting better!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //individual mood bar
  Widget _buildMoodBar(String day, String emoji, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 80 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            color: Colors.black.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

