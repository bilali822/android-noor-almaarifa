import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<Map<String, String>> _dailyVerses = [{'text': '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾', 'ref': 'الرعد - 28'}];

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (response) {});
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) { await androidPlugin.requestNotificationsPermission(); await androidPlugin.requestExactAlarmsPermission(); }
  }

  Future<void> showWelcomeNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails('welcome_channel', 'إشعارات الترحيب', importance: Importance.max, priority: Priority.high, color: Color(0xFF155E35), icon: '@mipmap/ic_launcher');
    await flutterLocalNotificationsPlugin.show(0, 'أهلاً بك في نور المعرفة 🌙', 'نسأل الله أن ينفعك', const NotificationDetails(android: androidDetails));
  }

  Future<void> scheduleDailyNotifications() async {
    for (int i = 2; i <= 7; i++) { await flutterLocalNotificationsPlugin.cancel(i); }
    final verse = _dailyVerses[0];
    await _scheduleNotification(id: 2, title: '﴿ آية اليوم ﴾', body: '${verse['text']}\n(${verse['ref']})', time: _nextInstanceOfTime(8, 0), color: const Color(0xFFD4AF37));
  }

  Future<void> _scheduleNotification({required int id, required String title, required String body, required tz.TZDateTime time, required Color color}) async {
    final AndroidNotificationDetails details = AndroidNotificationDetails('daily_channel_$id', title, importance: Importance.high, priority: Priority.high, color: color, icon: '@mipmap/ic_launcher', styleInformation: BigTextStyleInformation(body, contentTitle: title));
    await flutterLocalNotificationsPlugin.zonedSchedule(id, title, body, time, NotificationDetails(android: details), androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) scheduledDate = scheduledDate.add(const Duration(days: 1));
    return scheduledDate;
  }
}
