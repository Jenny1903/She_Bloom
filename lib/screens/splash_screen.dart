import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;


  //initializing state
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  //setting animation
  void _setupAnimations(){
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
    );

    //controls opacity
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    //controls size
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    //starts animating
    _controller.forward();
  }

  //connecting to next screen
  void _navigateToNextScreen(){
    Future.delayed(const Duration(seconds: 3), (){
      if (mounted){
        print('Login Screen');
      }

    });

  }

  //stopping animation
  @override
  void dispose(){
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

    //logo section widget
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

  //logo container
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
          // Icon(
          //   Icons.local_florist,
          //   size: 80,
          //   color: AppColors.darkPink,
          // ),
          const SizedBox(height: 10),
          _buildAppName(),
        ],
      ),
    ),
  );
}

   Widget _buildAppName(){
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'She',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'YesevaOne',
              fontWeight: FontWeight.w300,
              color: AppColors.darkPink,
              letterSpacing: 1,
            ),
          ),

          TextSpan(
            text: 'Bl',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'YesevaOne',
              fontWeight: FontWeight.w300,
              color: AppColors.darkPink,
              letterSpacing: 1,
            ),
          ),

          // const TextSpan(
          //   text: '🌸',
          //   style: TextStyle(fontSize: 30),
          // ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle, // Aligns flower with text center
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0), // Space around flower
                child: SvgPicture.asset(
                  'assets/flower.svg',
                  height: 40,
                  colorFilter: ColorFilter.mode(AppColors.darkPink, BlendMode.srcIn), // Optional: Tint the SVG
                ),
              ),
            ),
          ),

          TextSpan(
            text: 'om',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'YesevaOne',
              fontWeight: FontWeight.w300,
              color: AppColors.darkPink,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
  );
}

   Widget _buildTagline(){
     return Text(
       'REDEFINING FEMALE HEALTH CHOICES',
       style: TextStyle(
         fontSize: 12,
         letterSpacing: 2,
         color: AppColors.textMedium,
         fontWeight: FontWeight.bold,
       ),
     );
   }
}
