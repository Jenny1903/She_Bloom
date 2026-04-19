import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/colors.dart';
import '../services/mood_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedMood;
  double intensity = 0.5;
  bool _isSaving = false;
  List<Map<String, dynamic>> _weeklyData = [];
  bool _isLoadingChart = true;

  final MoodService _moodService = MoodService();

  //6 mood options with blob colors and backgrounds
  final List<Map<String, dynamic>> moods = [
    {
      'name': 'Very Pleasant',
      'blobColor': Color(0xFFFF8C42),
      'bgColor': Color(0xFFFFF5E6),
      'face': 'happy',
    },
    {
      'name': 'Pleasant',
      'blobColor': Color(0xFFFFC857),
      'bgColor': Color(0xFFFFFBE6),
      'face': 'smile',
    },
    {
      'name': 'Neutral',
      'blobColor': Color(0xFF64B5F6),
      'bgColor': Color(0xFFE3F2FD),
      'face': 'neutral',
    },
    {
      'name': 'Unpleasant',
      'blobColor': Color(0xFF9575CD),
      'bgColor': Color(0xFFF3E5F5),
      'face': 'sad',
    },
    {
      'name': 'Very Unpleasant',
      'blobColor': Color(0xFF7986CB),
      'bgColor': Color(0xFFE8EAF6),
      'face': 'crying',
    },
    {
      'name': 'Calm',
      'blobColor': Color(0xFF4DD0E1),
      'bgColor': Color(0xFFE0F7FA),
      'face': 'calm',
    },
  ];

  //Mood name ~ chart bar color
  final Map<String, Color> _moodColors = {
    'Very Pleasant': Color(0xFFFF8C42),
    'Pleasant': Color(0xFFFFC857),
    'Neutral': Color(0xFF64B5F6),
    'Unpleasant': Color(0xFF9575CD),
    'Very Unpleasant': Color(0xFF7986CB),
    'Calm': Color(0xFF4DD0E1),
    'No data': Color(0xFFE0E0E0),
  };

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    setState(() => _isLoadingChart = true);
    final data = await _moodService.getWeeklyMoodData();
    if (mounted) {
      setState(() {
        _weeklyData = data;
        _isLoadingChart = false;
      });
    }
  }

  void _selectMood(String moodName) {
    setState(() {
      selectedMood = moodName;
      intensity = 0.5;
    });
  }

  void _deselectMood() {
    setState(() => selectedMood = null);
  }

  Future<void> _saveMood() async {
    if (selectedMood == null || _isSaving) return;

    setState(() => _isSaving = true);

    final success = await _moodService.saveMood(
      moodName: selectedMood!,
      intensity: intensity,
      date: selectedDate,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mood logged: $selectedMood at ${(intensity * 100).toInt()}% intensity! ✨',
          ),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await _loadWeeklyData(); // Refresh chart with real data
      setState(() => selectedMood = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save mood. Please try again.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
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
                    Text('Today',
                        style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
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
      itemBuilder: (context, index) => _buildCollapsedMoodCard(moods[index]),
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
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
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
                    child: Center(child: _buildMediumFace(faceType)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    moodName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Full-screen expanded mood view

  Widget _buildFullScreenMood(Map<String, dynamic> mood) {
    final Color bgColor = mood['bgColor'] as Color? ?? AppColors.lightPink;
    final Color blobColor = mood['blobColor'] as Color? ?? AppColors.coral;
    final String moodName = mood['name'] as String? ?? 'Unknown';
    final String faceType = mood['face'] as String? ?? 'neutral';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Blob background
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(painter: BlobPainter(color: blobColor)),
            ),

            Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          size: 24, color: Colors.black87),
                      onPressed: _deselectMood,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ),

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

                const Spacer(),

                _buildCartoonFace(faceType),
                const SizedBox(height: 24),

                Text(
                  moodName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                //Intensity slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Very Unpleasant',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500)),
                          Text('Very Pleasant',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 8,
                          thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 16),
                          overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 28),
                          activeTrackColor: Colors.white.withOpacity(0.9),
                          inactiveTrackColor: Colors.black.withOpacity(0.15),
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: intensity,
                          onChanged: (v) => setState(() => intensity = v),
                        ),
                      ),
                      // Live intensity label
                      Text(
                        '${(intensity * 100).toInt()}% intensity',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                //Save / Next button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        disabledBackgroundColor: Colors.black45,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                          : const Text(
                        'Next',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartoonFace(String faceType) {
    return SizedBox(
      width: 120,
      height: 100,
      child: CustomPaint(painter: FacePainter(faceType: faceType)),
    );
  }

  Widget _buildMediumFace(String faceType) {
    return SizedBox(
      width: 50,
      height: 40,
      child: CustomPaint(painter: FacePainter(faceType: faceType, scale: 0.45)),
    );
  }

  //Weekly chart (live from Firestore)

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
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "This Week's Mood",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: _loadWeeklyData,
                    child: const Text(
                      'Refresh',
                      style: TextStyle(
                          color: AppColors.darkPink, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoadingChart)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_weeklyData.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No mood data yet this week 🌱',
                      style: TextStyle(color: AppColors.textMedium),
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _weeklyData.map((day) {
                    final moodName = day['moodName'] as String? ?? 'No data';
                    final barIntensity = (day['intensity'] as double?) ?? 0.0;
                    final dayName = day['dayName'] as String? ?? '';
                    final color = _moodColors[moodName] ?? const Color(0xFFE0E0E0);
                    return _buildMoodBar(dayName, barIntensity, color);
                  }).toList(),
                ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _getWeeklyInsight(),
                  style: const TextStyle(
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

  String _getWeeklyInsight() {
    if (_weeklyData.isEmpty) return '🌱 Start logging your mood!';
    final logged =
    _weeklyData.where((d) => d['moodName'] != 'No data').toList();
    if (logged.isEmpty) return '🌱 No entries yet this week';
    final avg = logged.fold<double>(0, (s, d) => s + (d['intensity'] as double)) /
        logged.length;
    if (avg >= 0.7) return '🌟 Your mood is great this week!';
    if (avg >= 0.4) return '🌤 Hanging in there — keep going!';
    return '💗 Tough week — be kind to yourself';
  }

  Widget _buildMoodBar(String day, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: height > 0 ? 80 * height : 6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color],
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
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

//BlobPainter

class BlobPainter extends CustomPainter {
  final Color color;
  BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.25)
      ..cubicTo(w * 0.15, h * 0.18, w * 0.35, h * 0.15, w * 0.5, h * 0.15)
      ..cubicTo(w * 0.65, h * 0.15, w * 0.85, h * 0.18, w, h * 0.25)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//FacePainter

class FacePainter extends CustomPainter {
  final String faceType;
  final double scale;
  FacePainter({required this.faceType, this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scale
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final s = scale;

    //eyes
    if (['happy', 'smile', 'neutral', 'calm'].contains(faceType)) {
      canvas.drawCircle(Offset(cx - 25 * s, 20 * s), 18 * s, white);
      canvas.drawCircle(Offset(cx + 25 * s, 20 * s), 18 * s, white);
      canvas.drawCircle(Offset(cx - 25 * s, 25 * s), 10 * s, fill);
      canvas.drawCircle(Offset(cx + 25 * s, 25 * s), 10 * s, fill);
    } else {
      canvas.drawCircle(Offset(cx - 25 * s, 20 * s), 8 * s, fill);
      canvas.drawCircle(Offset(cx + 25 * s, 20 * s), 8 * s, fill);
    }

    //mouth
    switch (faceType) {
      case 'happy':
        canvas.drawPath(
          Path()
            ..moveTo(cx - 35 * s, 60 * s)
            ..quadraticBezierTo(cx, 85 * s, cx + 35 * s, 60 * s),
          stroke,
        );
        final blush = Paint()
          ..color = Colors.pink.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx - 50 * s, 50 * s), 12 * s, blush);
        canvas.drawCircle(Offset(cx + 50 * s, 50 * s), 12 * s, blush);
        break;
      case 'smile':
        canvas.drawPath(
          Path()
            ..moveTo(cx - 30 * s, 65 * s)
            ..quadraticBezierTo(cx, 80 * s, cx + 30 * s, 65 * s),
          stroke,
        );
        break;
      case 'neutral':
        canvas.drawLine(
            Offset(cx - 25 * s, 70 * s), Offset(cx + 25 * s, 70 * s), stroke);
        break;
      case 'sad':
      case 'crying':
        canvas.drawPath(
          Path()
            ..moveTo(cx - 30 * s, 75 * s)
            ..quadraticBezierTo(cx, 60 * s, cx + 30 * s, 75 * s),
          stroke,
        );
        break;
      case 'calm':
        canvas.drawPath(
          Path()
            ..moveTo(cx - 20 * s, 70 * s)
            ..quadraticBezierTo(cx, 78 * s, cx + 20 * s, 70 * s),
          stroke,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}