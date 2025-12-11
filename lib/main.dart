import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:she_bloom/firebase_options.dart';
import 'package:she_bloom/screens/home_screen.dart';
import 'package:she_bloom/screens/splash_screen.dart';
import 'constants/colors.dart';

void main() async{

  //initializing Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home_screen': (context) => const HomeScreen(),
      },
    );
  }
}
