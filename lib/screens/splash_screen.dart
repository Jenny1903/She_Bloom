import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  //animating logo flower
  late AnimationController _flowerController;
  late Animation<double> _flowerRotationAnimation;
  late Animation<double> _flowerScaleAnimation;

  bool _startFlowerAnimation = false;

  //initializing state
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFlowerAnimation();
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

    //flower animation
    _controller.addStatusListener((status){
      if (status == AnimationStatus.completed){
        Future.delayed(const Duration(milliseconds: 300),(){
          if(mounted){
            setState(() {
              _startFlowerAnimation = true;
            });
            _flowerController.forward();
          }
        });
      }
    });
  }

  void _setupFlowerAnimation(){
    _flowerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
        vsync: this,
    );

    _flowerRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 6.0,
    ).animate(
      CurvedAnimation(
          parent: _flowerController,
          curve: Curves.easeInOut,
      ),
    );

    _flowerScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
          parent: _flowerController,
          curve: Curves.easeIn,
      ),
    );
  }

  //connecting to next screen
  void _navigateToNextScreen(){
    Future.delayed(const Duration(seconds: 4), (){
      if (mounted){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });

  }

  //stopping animation
  @override
  void dispose(){
    _controller.dispose();
    _flowerController.dispose();
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
          color: AppColors.primaryPink.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    ),

    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

           WidgetSpan(
             alignment: PlaceholderAlignment.middle,
             child: _startFlowerAnimation
                 ? AnimatedBuilder(
               animation: _flowerController,
               builder: (context, child) {
                 return Transform.rotate(
                   angle: _flowerRotationAnimation.value * 2 * 3.14159,
                   child: Transform.scale(
                     scale: _flowerScaleAnimation.value,
                     child: Opacity(
                       opacity: 1.0 - (_flowerScaleAnimation.value / 20),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 2.0),
                         child: SvgPicture.asset(
                           'assets/flower.svg',
                           height: 40,
                           colorFilter: ColorFilter.mode(
                             AppColors.darkPink,
                             BlendMode.srcIn,
                           ),
                         ),
                       ),
                     ),
                   ),
                 );
               },
             )
                 : Padding(
               padding: const EdgeInsets.symmetric(horizontal: 2.0),
               child: SvgPicture.asset(
                 'assets/flower.svg',
                 height: 40,
                 colorFilter: ColorFilter.mode(
                   AppColors.darkPink,
                   BlendMode.srcIn,
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
