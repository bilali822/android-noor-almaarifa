import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // 🌟 جلب الموقع وحساب الصلاة القادمة وتحديث الإشعار الدائم
  Future<void> updatePrayerTimesByLocation() async {
    try {
      // 1. طلب صلاحية الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      // 2. جلب الإحداثيات
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // دقة منخفضة أسرع وتكفي للصلاة
      );

      // 3. حساب مواقيت الصلاة باستخدام مكتبة Adhan
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.umm_al_qura.getParameters(); // افتراضي مكة، ويمكن تغييره
      params.madhab = Madhab.shafi;
      final date = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, date, params);

      // 4. تحديد الصلاة القادمة
      final nextPrayer = prayerTimes.nextPrayer();
      String nextName = 'الصلاة القادمة';
      DateTime nextTime = DateTime.now();

      if (nextPrayer == Prayer.fajr) { nextName = 'الفجر'; nextTime = prayerTimes.fajr; }
      else if (nextPrayer == Prayer.sunrise) { nextName = 'الشروق'; nextTime = prayerTimes.sunrise; }
      else if (nextPrayer == Prayer.dhuhr) { nextName = 'الظهر'; nextTime = prayerTimes.dhuhr; }
      else if (nextPrayer == Prayer.asr) { nextName = 'العصر'; nextTime = prayerTimes.asr; }
      else if (nextPrayer == Prayer.maghrib) { nextName = 'المغرب'; nextTime = prayerTimes.maghrib; }
      else if (nextPrayer == Prayer.isha) { nextName = 'العشاء'; nextTime = prayerTimes.isha; }

      final timeString = DateFormat('hh:mm a', 'ar').format(nextTime);
      final hijri = HijriCalendar.fromDate(DateTime.now());
      final hijriDate = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

      // 5. عرض الإشعار الدائم
      await showPersistentPrayerNotification(nextName, timeString, hijriDate);

    } catch (e) {
      debugPrint('Error calculating prayer times: $e');
      // في حال رفض المستخدم للموقع، نعرض إشعار افتراضي
      final hijri = HijriCalendar.fromDate(DateTime.now());
      await showPersistentPrayerNotification('صلاتك', '--:--', '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ');
    }
  }

  Future<void> showWelcomeNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'welcome_channel', 'إشعارات الترحيب',
      channelDescription: 'إشعار عند فتح التطبيق',
      importance: Importance.high,
      priority: Priority.high,
    );
    await flutterLocalNotificationsPlugin.show(
      0, 'أهلاً بك في نور المعرفة 🌙', 'نسأل الله أن ينفعك بما تقرأ وتتعلم.', const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showPersistentPrayerNotification(String nextPrayer, String time, String hijriDate) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_channel', 'مواقيت الصلاة',
      channelDescription: 'إشعار دائم بمواقيت الصلاة',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // يجعله دائم لا يمسح
      autoCancel: false,
      showWhen: false,
      onlyAlertOnce: true,
      icon: '@mipmap/ic_launcher',
    );
    
    await flutterLocalNotificationsPlugin.show(
      1, 'الصلاة القادمة: $nextPrayer ($time)', hijriDate, const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> scheduleDailyNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_channel', 'إشعارات يومية',
      channelDescription: 'إشعار يومي بآية أو حديث',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await flutterLocalNotificationsPlugin.cancel(2);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      2, 'آية اليوم 📖', '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾', _nextInstanceOfTime(8, 0),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) scheduledDate = scheduledDate.add(const Duration(days: 1));
    return scheduledDate;
  }
}
