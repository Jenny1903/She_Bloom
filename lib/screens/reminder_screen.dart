import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/colors.dart';
import '../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final NotificationService _notifService = NotificationService();

  //period
  bool _periodEnabled = false;
  TimeOfDay _periodTime = const TimeOfDay(hour: 8, minute: 0);

  //mood
  bool _moodEnabled = false;
  TimeOfDay _moodTime = const TimeOfDay(hour: 20, minute: 0);

  //medication
  bool _medicationEnabled = false;
  String _medicationName = 'My Medication';
  final List<TimeOfDay> _medicationTimes = [
    const TimeOfDay(hour: 8, minute: 0),
  ];

  //water
  bool _waterEnabled = false;
  int _waterInterval = 2; // hours

  //custom reminders
  final List<_CustomReminder> _customReminders = [];

  bool _isSaving = false;

  //init
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifService.requestPermissions();
  }

  //helper

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.darkPink,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);

    // Period
    if (_periodEnabled) {
      await _notifService.schedulePeriodReminder(time: _periodTime);
    } else {
      await _notifService.cancelPeriodReminder();
    }

    //Mood
    if (_moodEnabled) {
      await _notifService.scheduleMoodReminder(time: _moodTime);
    } else {
      await _notifService.cancelMoodReminder();
    }

    //Medication
    if (_medicationEnabled) {
      await _notifService.cancelAllMedicationReminders();
      for (int i = 0; i < _medicationTimes.length; i++) {
        await _notifService.scheduleMedicationReminder(
          time: _medicationTimes[i],
          medicationName: _medicationName,
          slot: i,
        );
      }
    } else {
      await _notifService.cancelAllMedicationReminders();
    }

    //Water
    if (_waterEnabled) {
      await _notifService.scheduleWaterReminders(
          intervalHours: _waterInterval);
    } else {
      await _notifService.cancelAllWaterReminders();
    }

    //Custom: save only new ones (those without an assigned ID yet)
    for (final r in _customReminders) {
      if (!r.saved) {
        r.notifId = await _notifService.scheduleCustomReminder(
          title: r.title,
          body: r.body,
          time: r.time,
        );
        r.saved = true;
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reminders saved successfully!'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  //build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPink,
              const Color(0xFFE1BEE7),
              const Color(0xFFB2DFDB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildPeriodCard(),
                      const SizedBox(height: 16),
                      _buildMoodCard(),
                      const SizedBox(height: 16),
                      _buildMedicationCard(),
                      const SizedBox(height: 16),
                      _buildWaterCard(),
                      const SizedBox(height: 16),
                      _buildCustomCard(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 24),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Text(
            'Reminders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 48), // balance
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health\nReminders',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stay on top of your wellness routine',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  //Glassmorphism card wrapper

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  //Row: label + time picker button
  Widget _timeRow({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500)),
            Row(
              children: [
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.access_time_rounded,
                    size: 18, color: AppColors.darkPink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Section header row (title + toggle)

  Widget _sectionHeader({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.darkPink,
        ),
      ],
    );
  }

  //period card

  Widget _buildPeriodCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            emoji: '🌸',
            title: 'Period Tracker',
            subtitle: 'Daily reminder to log your cycle',
            value: _periodEnabled,
            onChanged: (v) => setState(() => _periodEnabled = v),
          ),
          if (_periodEnabled) ...[
            const SizedBox(height: 16),
            _timeRow(
              label: 'Reminder time',
              time: _periodTime,
              onTap: () async {
                final t = await _pickTime(_periodTime);
                if (t != null) setState(() => _periodTime = t);
              },
            ),
          ],
        ],
      ),
    );
  }

  //mood card

  Widget _buildMoodCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            emoji: '💜',
            title: 'Mood Check-in',
            subtitle: 'Daily nudge to log how you feel',
            value: _moodEnabled,
            onChanged: (v) => setState(() => _moodEnabled = v),
          ),
          if (_moodEnabled) ...[
            const SizedBox(height: 16),
            _timeRow(
              label: 'Reminder time',
              time: _moodTime,
              onTap: () async {
                final t = await _pickTime(_moodTime);
                if (t != null) setState(() => _moodTime = t);
              },
            ),
          ],
        ],
      ),
    );
  }

  //medication card

  Widget _buildMedicationCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            emoji: '💊',
            title: 'Medication',
            subtitle: 'Up to 3 reminders per day',
            value: _medicationEnabled,
            onChanged: (v) => setState(() => _medicationEnabled = v),
          ),
          if (_medicationEnabled) ...[
            const SizedBox(height: 16),
            // Medication name field
            TextField(
              decoration: InputDecoration(
                hintText: 'Medication name',
                hintStyle: TextStyle(color: AppColors.textMedium),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.darkPink, width: 1.5),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) => _medicationName = v,
            ),
            const SizedBox(height: 12),
            // Time slots
            ...List.generate(_medicationTimes.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _timeRow(
                        label: 'Dose ${i + 1}',
                        time: _medicationTimes[i],
                        onTap: () async {
                          final t = await _pickTime(_medicationTimes[i]);
                          if (t != null) {
                            setState(() => _medicationTimes[i] = t);
                          }
                        },
                      ),
                    ),
                    if (i > 0) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _medicationTimes.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            if (_medicationTimes.length < 3)
              TextButton.icon(
                onPressed: () => setState(() => _medicationTimes
                    .add(const TimeOfDay(hour: 12, minute: 0))),
                icon: Icon(Icons.add, color: AppColors.darkPink, size: 18),
                label: Text('Add dose time',
                    style: TextStyle(
                        color: AppColors.darkPink, fontWeight: FontWeight.w600)),
              ),
          ],
        ],
      ),
    );
  }

  //water card

  Widget _buildWaterCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            emoji: '💧',
            title: 'Water Intake',
            subtitle: 'Reminders to stay hydrated',
            value: _waterEnabled,
            onChanged: (v) => setState(() => _waterEnabled = v),
          ),
          if (_waterEnabled) ...[
            const SizedBox(height: 16),
            Text('Remind me every:',
                style:
                TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3, 4].map((h) {
                final selected = _waterInterval == h;
                return GestureDetector(
                  onTap: () => setState(() => _waterInterval = h),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.darkPink
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.darkPink
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                    child: Text(
                      '${h}h',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : AppColors.textDark,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Reminders from 8 AM to 10 PM',
                style:
                TextStyle(fontSize: 12, color: AppColors.textMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }

  //custom reminders card

  Widget _buildCustomCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Custom Reminders',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    Text('Your personal health reminders',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMedium)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _addCustomReminder,
                icon: Icon(Icons.add, color: AppColors.darkPink, size: 18),
                label: Text('Add',
                    style: TextStyle(
                        color: AppColors.darkPink, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (_customReminders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  'No custom reminders yet.\nTap Add to create one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMedium, fontSize: 13),
                ),
              ),
            )
          else ...[
            const SizedBox(height: 12),
            ...List.generate(_customReminders.length, (i) {
              final r = _customReminders[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.7)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(r.body,
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMedium),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 14, color: AppColors.darkPink),
                              const SizedBox(width: 4),
                              Text(_formatTime(r.time),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkPink,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (r.saved && r.notifId != null) {
                          await _notifService.cancelCustomReminder(r.notifId!);
                        }
                        setState(() => _customReminders.removeAt(i));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  //add custom reminder bottom sheet

  Future<void> _addCustomReminder() async {
    String title = '';
    String body = '';
    TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('New Reminder',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 20),
                TextField(
                  decoration: _inputDecoration('Title (e.g. Vitamins)'),
                  onChanged: (v) => title = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: _inputDecoration('Message (e.g. Time for your vitamins!)'),
                  onChanged: (v) => body = v,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final t = await _pickTime(time);
                    if (t != null) setModal(() => time = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time',
                            style: TextStyle(
                                color: AppColors.textMedium, fontSize: 14)),
                        Row(
                          children: [
                            Text(_formatTime(time),
                                style: TextStyle(
                                    color: AppColors.darkPink,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            const SizedBox(width: 6),
                            Icon(Icons.access_time_rounded,
                                color: AppColors.darkPink, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      if (title.trim().isEmpty) return;
                      setState(() {
                        _customReminders.add(_CustomReminder(
                          title: title.trim(),
                          body: body.trim().isEmpty
                              ? 'Time for your reminder!'
                              : body.trim(),
                          time: time,
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Add Reminder',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMedium),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkPink, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  //save button

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveAll,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPink,
          disabledBackgroundColor: AppColors.darkPink.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
        ),
        child: _isSaving
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2.5),
        )
            : const Text(
          'Save Reminders',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}

//Custom reminder data model

class _CustomReminder {
  String title;
  String body;
  TimeOfDay time;
  bool saved;
  int? notifId;

  _CustomReminder({
    required this.title,
    required this.body,
    required this.time,
    this.saved = false,
    this.notifId,
  });
}