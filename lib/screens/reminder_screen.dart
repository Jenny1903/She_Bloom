import 'package:flutter/material.dart';
import 'package:she_bloom/constants/colors.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {

  //reminders with status/time
  List<Map<String, dynamic>> reminders=[
    {
      'icon': Icons.water_drop,
      'title': 'Period Tracking',
      'subtitle': 'Daily period cycle reminder',
      'time': '9:00 AM',
      'enabled': true,
      'color': Color(0xFFE91E63),
    },
    {
      'icon': Icons.medication,
      'title': 'Medication',
      'subtitle': 'Birth control pill reminder',
      'time': '8:00 PM',
      'enabled': true,
      'color': Color(0xFF9C27B0),
    },
    {
      'icon': Icons.local_hospital,
      'title': 'Doctor Appointment',
      'subtitle': 'Monthly checkup reminder',
      'time': '10:00 AM',
      'enabled': false,
      'color': Color(0xFF2196F3),
    },
    {
      'icon': Icons.self_improvement,
      'title': 'Workout',
      'subtitle': 'Daily exercise reminder',
      'time': '7:00 AM',
      'enabled': true,
      'color': Color(0xFF4CAF50),
    },
    {
      'icon': Icons.restaurant,
      'title': 'Meal Time',
      'subtitle': 'Healthy eating reminder',
      'time': '1:00 PM',
      'enabled': false,
      'color': Color(0xFFFF9800),
    },
    {
      'icon': Icons.bedtime,
      'title': 'Sleep Time',
      'subtitle': 'Bedtime reminder',
      'time': '10:00 PM',
      'enabled': true,
      'color': Color(0xFF673AB7),
    },
    {
      'icon': Icons.mood,
      'title': 'Mood Check',
      'subtitle': 'Log your daily mood',
      'time': '8:00 PM',
      'enabled': false,
      'color': Color(0xFFF44336),
    },

  ];

  void _toggleReminder(int index){
    setState(() {
      reminders[index]['enabled'] = !reminders[index]['enabled'];
    });

    String status = reminders[index]['enabled'] ? 'enabled' : 'disabled';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reminders[index]['title']} $status'),
        duration: const Duration(seconds: 1),
        backgroundColor: reminders[index]['enabled'] ? Colors.green : Colors.grey,
      ),
    );
  }

  void _editReminderTime(int index) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        reminders[index]['time'] = picked.format(context);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder time updated to ${picked.format(context)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        //back button
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.darkGrey),
        ),
        title: Text(
          'Reminders',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.darkPink),
            onPressed: () {
              //todo: adding a reminder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Add new reminder -Coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              //list
              _buildStateCard(),

              const SizedBox(height: 24),

              ...List.generate(
                  reminders.length,
                  (index) => _buildReminderCard(index),
              ),

              const SizedBox(height: 20),
            ],
          ),
      ),
    );
  }

  //state card
  Widget _buildStateCard(){
    int activeCount = reminders.where((r) => r['enabled'] == true).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkPink, AppColors.coral],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
          children: [
      Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.notifications_active,
        size: 32,
        color: Colors.white,
      ),
    ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$activeCount Active',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Reminders set for today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }

  //reminder card
  Widget _buildReminderCard(int index){
    final reminder = reminders[index];
    final isEnabled = reminder['enabled'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(

        color: isEnabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
              ? reminder['color'].withOpacity(0.3)
              : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editReminderTime(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (reminder['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    reminder['icon'] as IconData,
                    color: reminder['color'] as Color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isEnabled ? AppColors.darkGrey : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: isEnabled ? AppColors.textMedium : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: isEnabled ? AppColors.darkPink : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reminder['time'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isEnabled ? AppColors.darkPink : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Toggle switch
                Switch(
                  value: isEnabled,
                  onChanged: (value) => _toggleReminder(index),
                  activeColor: reminder['color'] as Color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}