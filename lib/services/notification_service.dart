import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  //Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  //notification ID ranges(avoid collisions)
  // Period reminders:    100–199
  // Mood reminders:      200–299
  // Medication:          300–399
  // Water intake:        400–499
  // Custom reminders:    500–999
  static const int _periodBaseId = 100;
  static const int _moodBaseId = 200;
  static const int _medicationBaseId = 300;
  static const int _waterBaseId = 400;
  static const int _customBaseId = 500;

//initialization
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: navigate based on response.payload
    // e.g. if payload == 'mood' → push MoodTrackerScreen
  }

  //permission request

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool granted = false;
    if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
    }
    if (ios != null) {
      granted = await ios.requestPermissions(
          alert: true, badge: true, sound: true) ??
          false;
    }
    return granted;
  }

  //notification details helper

  NotificationDetails _details({
    required String channelId,
    required String channelName,
    required String channelDesc,
    String? sound,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: const BigTextStyleInformation(''),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  //schedule helper
  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  //period reminder
  Future<void> schedulePeriodReminder({
    required TimeOfDay time,
    String title = '🌸 Period Tracker',
    String body = 'Don\'t forget to log your cycle today!',
  }) async {
    await _plugin.zonedSchedule(
      _periodBaseId,
      title,
      body,
      _nextInstanceOf(time),
      _details(
        channelId: 'period_channel',
        channelName: 'Period Reminders',
        channelDesc: 'Daily reminders to log your menstrual cycle',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      payload: 'period',
    );
  }

  Future<void> cancelPeriodReminder() async {
    await _plugin.cancel(_periodBaseId);
  }

  //mood reminder

  Future<void> scheduleMoodReminder({
    required TimeOfDay time,
    String title = '💜 Mood Check-in',
    String body = 'How are you feeling today? Take a moment to log your mood.',
  }) async {
    await _plugin.zonedSchedule(
      _moodBaseId,
      title,
      body,
      _nextInstanceOf(time),
      _details(
        channelId: 'mood_channel',
        channelName: 'Mood Reminders',
        channelDesc: 'Daily reminders to log your mood',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'mood',
    );
  }

  Future<void> cancelMoodReminder() async {
    await _plugin.cancel(_moodBaseId);
  }

  //medication reminder

  //Schedule up to 3 medication reminders per day (morning / afternoon / evening).
  Future<void> scheduleMedicationReminder({
    required TimeOfDay time,
    required String medicationName,
    int slot = 0, // 0, 1, or 2 for up to 3 daily slots
  }) async {
    await _plugin.zonedSchedule(
      _medicationBaseId + slot,
      'Medication Reminder',
      'Time to take your $medicationName!',
      _nextInstanceOf(time),
      _details(
        channelId: 'medication_channel',
        channelName: 'Medication Reminders',
        channelDesc: 'Reminders to take your medication on time',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'medication',
    );
  }

  Future<void> cancelMedicationReminder({int slot = 0}) async {
    await _plugin.cancel(_medicationBaseId + slot);
  }

  Future<void> cancelAllMedicationReminders() async {
    for (int i = 0; i < 3; i++) {
      await _plugin.cancel(_medicationBaseId + i);
    }
  }

  //water intake reminder

  //Schedule repeating water reminders every [intervalHours] hours
  //from [startTime] to [endTime] (e.g. 8 AM to 10 PM).
  Future<void> scheduleWaterReminders({
    int intervalHours = 2,
    int startHour = 8,
    int endHour = 22,
  }) async {
    await cancelAllWaterReminders();
    int id = _waterBaseId;
    for (int hour = startHour; hour <= endHour; hour += intervalHours) {
      final time = TimeOfDay(hour: hour, minute: 0);
      await _plugin.zonedSchedule(
        id++,
        '💧 Hydration Reminder',
        'Time to drink a glass of water! Stay hydrated 🌊',
        _nextInstanceOf(time),
        _details(
          channelId: 'water_channel',
          channelName: 'Water Reminders',
          channelDesc: 'Regular reminders to drink water throughout the day',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'water',
      );
    }
  }

  Future<void> cancelAllWaterReminders() async {
    for (int i = _waterBaseId; i < _waterBaseId + 10; i++) {
      await _plugin.cancel(i);
    }
  }

  //custom reminder
  Future<int> scheduleCustomReminder({
    required String title,
    required String body,
    required TimeOfDay time,
    bool repeatDaily = true,
  }) async {
    // Find next available ID in custom range
    final pending = await _plugin.pendingNotificationRequests();
    final usedIds = pending.map((n) => n.id).toSet();
    int id = _customBaseId;
    while (usedIds.contains(id) && id < 1000) {
      id++;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOf(time),
      _details(
        channelId: 'custom_channel',
        channelName: 'Custom Reminders',
        channelDesc: 'Your personal health reminders',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
      repeatDaily ? DateTimeComponents.time : null,
      payload: 'custom',
    );
    return id;
  }

  Future<void> cancelCustomReminder(int id) async {
    await _plugin.cancel(id);
  }

  //utility

  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    return _plugin.pendingNotificationRequests();
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}