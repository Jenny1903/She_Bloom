import 'package:flutter/material.dart';
import 'dart:async';

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

  //list of mood emojis
  final List<String> _images = [
    'assets/images/happy.jpg',
    'assets/images/calm.jpg',
    'assets/images/okay.jpg',
    'assets/images/sad.jpg',
    'assets/images/crying.jpg',
    'assets/images/angry.jpg',
    'assets/images/anxious.jpg',
    'assets/images/tired.jpg',
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
          _currentIndex = (_currentIndex + 1) % _images.length;
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image - fills entire container
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    _images[_currentIndex],
                    key: ValueKey<int>(_currentIndex),
                    fit: BoxFit.cover, // COVER fills entire space!
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: widget.backgroundColor.withOpacity(0.3),
                        child: Icon(
                          Icons.mood,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                ),
              ),

              //gradient overlay for better text visibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              //title on top
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
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