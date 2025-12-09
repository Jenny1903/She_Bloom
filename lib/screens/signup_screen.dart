import 'package:flutter/material.dart';
import 'package:she_bloom/constants/colors.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      appBar: AppBar(
        backgroundColor: AppColors.lightPink,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: AppColors.darkPink,
            ),
            const SizedBox(height: 20),
            Text(
              'SIGN UP SCREEN',
              style: TextStyle(
                fontFamily: 'Gaqire',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming soon! 🚀',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),

    );
  }
}
