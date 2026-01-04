import 'package:flutter/material.dart';
import 'package:she_bloom/constants/colors.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () =>
          Navigator.pop(context),
            icon: Icon(Icons.arrow_back,
              color: AppColors.darkGrey),
            ),
          title: Text(
            'Reminders',
            style: TextStyle(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
  }
}
