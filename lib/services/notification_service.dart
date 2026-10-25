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

  // 🌟 جلب الموقع وحساب الصلوات وتصميم الإشعار الاحترافي
  Future<void> updatePrayerTimesByLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.umm_al_qura.getParameters();
      params.madhab = Madhab.shafi;
      final date = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, date, params);

      // 1. تحديد الصلاة القادمة
      final nextPrayer = prayerTimes.nextPrayer();
      String nextName = 'الصلاة القادمة';
      DateTime nextTime = DateTime.now();

      if (nextPrayer == Prayer.fajr) { nextName = 'الفجر'; nextTime = prayerTimes.fajr; }
      else if (nextPrayer == Prayer.sunrise) { nextName = 'الشروق'; nextTime = prayerTimes.sunrise; }
      else if (nextPrayer == Prayer.dhuhr) { nextName = 'الظهر'; nextTime = prayerTimes.dhuhr; }
      else if (nextPrayer == Prayer.asr) { nextName = 'العصر'; nextTime = prayerTimes.asr; }
      else if (nextPrayer == Prayer.maghrib) { nextName = 'المغرب'; nextTime = prayerTimes.maghrib; }
      else if (nextPrayer == Prayer.isha) { nextName = 'العشاء'; nextTime = prayerTimes.isha; }

      final timeFormat = DateFormat('hh:mm a', 'ar');
      
      // 2. تنسيق التاريخ الهجري
      final hijri = HijriCalendar.fromDate(DateTime.now());
      final hijriDate = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

      // 3. بناء جدول الصلوات (يظهر عند سحب الإشعار)
      final schedule = """
━━━━━━━━━━━━━━━━━
🕌 مواقيت الصلوات اليوم
━━━━━━━━━━━━━━━━━
🌅 الفجر:    ${timeFormat.format(prayerTimes.fajr)}
🌞 الظهر:    ${timeFormat.format(prayerTimes.dhuhr)}
🌤️ العصر:    ${timeFormat.format(prayerTimes.asr)}
🌇 المغرب:  ${timeFormat.format(prayerTimes.maghrib)}
🌙 العشاء:   ${timeFormat.format(prayerTimes.isha)}
━━━━━━━━━━━━━━━━━
""";

      // 4. عرض الإشعار الدائم
      await showPersistentPrayerNotification(nextName, timeFormat.format(nextTime), hijriDate, schedule);

    } catch (e) {
      debugPrint('Error calculating prayer times: $e');
      final hijri = HijriCalendar.fromDate(DateTime.now());
      await showPersistentPrayerNotification('صلاتك', '--:--', '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ', 'يرجى تفعيل خدمة الموقع (GPS) لحساب المواقيت بدقة.');
    }
  }

  Future<void> showWelcomeNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'welcome_channel', 'إشعارات الترحيب',
      channelDescription: 'إشعار عند فتح التطبيق',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF155E35), // لون التطبيق الأخضر
    );
    await flutterLocalNotificationsPlugin.show(
      0, 'أهلاً بك في نور المعرفة 🌙', 'نسأل الله أن ينفعك بما تقرأ وتتعلم.', const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showPersistentPrayerNotification(String nextPrayer, String time, String hijriDate, String schedule) async {
    // 🌟 تصميم الإشعار الاحترافي
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_channel', 'مواقيت الصلاة',
      channelDescription: 'إشعار دائم بمواقيت الصلاة والتاريخ الهجري',
      importance: Importance.low, // منخفض لكي لا يزعج المستخدم برنة
      priority: Priority.low,
      ongoing: true, // يجعله دائم لا يمكن مسحه
      autoCancel: false,
      showWhen: false,
      onlyAlertOnce: true,
      color: const Color(0xFF155E35), // لون الأيقونة أخضر
      icon: '@mipmap/ic_launcher',
      // إعدادات النص الكبير (عند سحب الإشعار)
      styleInformation: BigTextStyleInformation(
        schedule, // النص الكبير الذي يظهر عند السحب
        contentTitle: '$hijriDate\n🕌 $nextPrayer ($time)', // العنوان الرئيسي
        summaryText: 'تطبيق نور المعرفة', // النص الصغير
      ),
      // إعدادات النص العادي (قبل السحب)
      ticker: 'تحديث مواقيت الصلاة',
    );
    
    await flutterLocalNotificationsPlugin.show(
      1, 
      '$hijriDate\n🕌 $nextPrayer ($time)', 
      'اسحب للأسفل لعرض جميع المواقيت ⬇️', 
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> scheduleDailyNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_channel', 'إشعارات يومية',
      channelDescription: 'إشعار يومي بآية أو حديث',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      color: Color(0xFF155E35),
    );
    await flutterLocalNotificationsPlugin.cancel(2);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      2, '📖 آية اليوم | نور المعرفة', '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾', _nextInstanceOfTime(8, 0),
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
