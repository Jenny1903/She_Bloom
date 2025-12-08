import 'package:flutter/material.dart';
import 'package:she_bloom/screens/splash_screen.dart';
import 'constants/colors.dart';

void main(){
  runApp(const SheBloom());
}

class SheBloom extends StatelessWidget {
  const SheBloom({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SheBloom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryPink,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
