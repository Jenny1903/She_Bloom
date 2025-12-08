import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }


  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }


  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {

        print('Login Screen');
      }
    }
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildLogoSection(),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildLogoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogoContainer(),
        const SizedBox(height: 30),
        _buildTagline(),
      ],
    );
  }


  Widget _buildLogoContainer() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist,
              size: 80,
              color: AppColors.darkPink,
            ),
            const SizedBox(height: 10),
            _buildAppName(),
          ],
        ),
      ),
    );
  }


  Widget _buildAppName() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'She',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: AppColors.darkGrey,
              letterSpacing: 1,
            ),
          ),
          TextSpan(
            text: 'BL',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPink,
              letterSpacing: 1,
            ),
          ),
          const TextSpan(
            text: '🌸',
            style: TextStyle(fontSize: 24),
          ),
          TextSpan(
            text: 'om',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: AppColors.darkGrey,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTagline() {
    return Text(
      'REDEFINING FEMALE HEALTH CHOICES',
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 2,
        color: AppColors.textMedium,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
