import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../constants/colors.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedMood;
  double intensity = 0.5;

  //6 mood options with blob colors and backgrounds
  final List<Map<String, dynamic>> moods = [
    {
      'name': 'Very Pleasant',
      'blobColor': Color(0xFFFF8C42), // Orange blob
      'bgColor': Color(0xFFFFF5E6), // Cream background
      'face': 'happy',
    },
    {
      'name': 'Pleasant',
      'blobColor': Color(0xFFFFC857), // Yellow blob
      'bgColor': Color(0xFFFFFBE6), // Light yellow background
      'face': 'smile',
    },
    {
      'name': 'Neutral',
      'blobColor': Color(0xFF64B5F6), // Blue blob
      'bgColor': Color(0xFFE3F2FD), // Light blue background
      'face': 'neutral',
    },
    {
      'name': 'Unpleasant',
      'blobColor': Color(0xFF9575CD), // Purple blob
      'bgColor': Color(0xFFF3E5F5), // Light purple background
      'face': 'sad',
    },
    {
      'name': 'Very Unpleasant',
      'blobColor': Color(0xFF7986CB), // Indigo blob
      'bgColor': Color(0xFFE8EAF6), // Light indigo background
      'face': 'crying',
    },
    {
      'name': 'Calm',
      'blobColor': Color(0xFF4DD0E1), // Cyan blob
      'bgColor': Color(0xFFE0F7FA), // Light cyan background
      'face': 'calm',
    },
  ];

  void _selectMood(String moodName) {
    setState(() {
      selectedMood = moodName;
      intensity = 0.5;
    });
  }

  void _deselectMood() {
    setState(() {
      selectedMood = null;
    });
  }

  void _saveMood() {
    if (selectedMood == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mood logged: $selectedMood at ${(intensity * 100).toInt()}% intensity! ✨'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    setState(() {
      selectedMood = null;
      intensity = 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedMood != null) {
      final mood = moods.firstWhere((m) => m['name'] == selectedMood);
      return _buildFullScreenMood(mood);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPink,
              Color(0xFFE1BEE7),
              Color(0xFFB2DFDB),
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

  Widget _buildAppBar() {
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

  Widget _buildHeader() {
    return const Text(
      'Tell me how you\nfeel today',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        height: 1.2,
      ),
    );
  }

  Widget _buildDateCard() {
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
                child: const Icon(Icons.calendar_today, color: AppColors.textMedium),
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
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
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

  Widget _buildMoodBubbles() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        return _buildCollapsedMoodCard(moods[index]);
      },
    );
  }

  Widget _buildCollapsedMoodCard(Map<String, dynamic> mood) {
    final Color blobColor = mood['blobColor'] as Color? ?? AppColors.coral;
    final String moodName = mood['name'] as String? ?? 'Unknown';
    final String faceType = mood['face'] as String? ?? 'neutral';

    return GestureDetector(
      onTap: () => _selectMood(moodName),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Face circle with gradient
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          blobColor.withOpacity(0.8),
                          blobColor.withOpacity(0.6),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: blobColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _buildMediumFace(faceType),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mood name
                  Text(
                    moodName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //full-screen mood with blob shape
  Widget _buildFullScreenMood(Map<String, dynamic> mood) {
    final Color bgColor = mood['bgColor'] as Color? ?? AppColors.lightPink;
    final Color blobColor = mood['blobColor'] as Color? ?? AppColors.coral;
    final String moodName = mood['name'] as String? ?? 'Unknown';
    final String faceType = mood['face'] as String? ?? 'neutral';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            //back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.black87),
                  onPressed: _deselectMood,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),

            //title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Tell me how you feel today',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            //blob with face
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Blob shape
                    CustomPaint(
                      size: const Size(300, 320),
                      painter: BlobPainter(color: blobColor),
                    ),
                    // Face and text on top
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCartoonFace(faceType),
                        const SizedBox(height: 80),
                        Text(
                          moodName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //intensity slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Very Unpleasant',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        'Very Pleasant',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 12,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                      activeTrackColor: Colors.white.withOpacity(0.8),
                      inactiveTrackColor: Colors.black.withOpacity(0.15),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: intensity,
                      onChanged: (value) {
                        setState(() {
                          intensity = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  //build cartoon faces
  Widget _buildCartoonFace(String faceType) {
    return SizedBox(
      width: 120,
      height: 100,
      child: CustomPaint(
        painter: FacePainter(faceType: faceType),
      ),
    );
  }

  Widget _buildTinyFace(String faceType) {
    return SizedBox(
      width: 30,
      height: 25,
      child: CustomPaint(
        painter: FacePainter(faceType: faceType, scale: 0.25),
      ),
    );
  }

  Widget _buildMediumFace(String faceType) {
    return SizedBox(
      width: 50,
      height: 40,
      child: CustomPaint(
        painter: FacePainter(faceType: faceType, scale: 0.45),
      ),
    );
  }

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
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.darkPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMoodBar('Mon', 0.8, AppColors.coral),
                  _buildMoodBar('Tue', 0.6, Color(0xFF26A69A)),
                  _buildMoodBar('Wed', 0.4, Color(0xFF42A5F5)),
                  _buildMoodBar('Thu', 0.7, Color(0xFF7E57C2)),
                  _buildMoodBar('Fri', 0.3, Color(0xFF5C6BC0)),
                  _buildMoodBar('Sat', 0.85, Color(0xFFFFA726)),
                  _buildMoodBar('Sun', 0.9, AppColors.coral),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '🌟 Your mood is getting better!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
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

  Widget _buildMoodBar(String day, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
            color: AppColors.textMedium,
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

//custom painter for blob shape
class BlobPainter extends CustomPainter {
  final Color color;

  BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    //organic blob shape with curves
    path.moveTo(w * 0.5, 0);
    path.quadraticBezierTo(w * 0.8, h * 0.1, w * 0.9, h * 0.35);
    path.quadraticBezierTo(w, h * 0.6, w * 0.85, h * 0.8);
    path.quadraticBezierTo(w * 0.7, h, w * 0.5, h);
    path.quadraticBezierTo(w * 0.3, h, w * 0.15, h * 0.8);
    path.quadraticBezierTo(0, h * 0.6, w * 0.1, h * 0.35);
    path.quadraticBezierTo(w * 0.2, h * 0.1, w * 0.5, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//custom painter for cartoon faces
class FacePainter extends CustomPainter {
  final String faceType;
  final double scale;

  FacePainter({required this.faceType, this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final s = scale;

    //draw eyes based on face type
    if (faceType == 'happy' || faceType == 'smile' || faceType == 'neutral' || faceType == 'calm') {
      // White of eyes
      canvas.drawCircle(Offset(centerX - 25 * s, 20 * s), 18 * s, eyePaint);
      canvas.drawCircle(Offset(centerX + 25 * s, 20 * s), 18 * s, eyePaint);
      // Black pupils
      canvas.drawCircle(Offset(centerX - 25 * s, 25 * s), 10 * s, paint);
      canvas.drawCircle(Offset(centerX + 25 * s, 25 * s), 10 * s, paint);
    } else if (faceType == 'sad' || faceType == 'crying') {
      // Sad eyes (smaller)
      canvas.drawCircle(Offset(centerX - 25 * s, 20 * s), 8 * s, paint);
      canvas.drawCircle(Offset(centerX + 25 * s, 20 * s), 8 * s, paint);
    }

    //draw mouth
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * s
      ..strokeCap = StrokeCap.round;

    if (faceType == 'happy') {

      //big smile
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 35 * s, 60 * s);
      mouthPath.quadraticBezierTo(centerX, 85 * s, centerX + 35 * s, 60 * s);
      canvas.drawPath(mouthPath, mouthPaint);
    } else if (faceType == 'smile') {

      //medium smile
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 30 * s, 65 * s);
      mouthPath.quadraticBezierTo(centerX, 80 * s, centerX + 30 * s, 65 * s);
      canvas.drawPath(mouthPath, mouthPaint);
    } else if (faceType == 'neutral') {

      //straight line
      canvas.drawLine(Offset(centerX - 25 * s, 70 * s), Offset(centerX + 25 * s, 70 * s), mouthPaint);
    } else if (faceType == 'sad' || faceType == 'crying') {

      // Frown
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 30 * s, 75 * s);
      mouthPath.quadraticBezierTo(centerX, 60 * s, centerX + 30 * s, 75 * s);
      canvas.drawPath(mouthPath, mouthPaint);
    } else if (faceType == 'calm') {

      //small smile
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 20 * s, 70 * s);
      mouthPath.quadraticBezierTo(centerX, 78 * s, centerX + 20 * s, 70 * s);
      canvas.drawPath(mouthPath, mouthPaint);
    }

    //blush for happy face
    if (faceType == 'happy') {
      final blushPaint = Paint()
        ..color = Colors.pink.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(centerX - 50 * s, 50 * s), 12 * s, blushPaint);
      canvas.drawCircle(Offset(centerX + 50 * s, 50 * s), 12 * s, blushPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}