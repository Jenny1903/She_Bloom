import 'package:flutter/material.dart';
import 'dart:async';
import 'package:she_bloom/constants/colors.dart';

class MoodCarouselCard extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final VoidCallback onTap;
  final double? height;

  const MoodCarouselCard({
    Key? key,
    required this.title,
    required this.backgroundColor,
    required this.onTap,
    this.height,
  }) : super(key: key);

  @override
  State<MoodCarouselCard> createState() => _MoodCarouselCardState();
}

class _MoodCarouselCardState extends State<MoodCarouselCard> {
  int _currentIndex = 0;
  Timer? _timer;

  // List of mood emojis
  final List<String> _emojis = [
    '😊', // Happy
    '😌', // Calm
    '😐', // Okay
    '😔', // Sad
    '😢', // Crying
    '😡', // Angry
    '😰', // Anxious
    '😴', // Tired
  ];

  @override
  void initState() {
    super.initState();
    _startCarousel();
  }

  void _startCarousel() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _emojis.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: widget.height ?? 120,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              //emoji Carousel
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    // Fade + Scale transition
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _emojis[_currentIndex],
                    key: ValueKey<int>(_currentIndex),
                    style: const TextStyle(
                      fontSize: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
