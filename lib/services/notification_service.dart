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
  
  String nextPrayerName = 'جاري التحديد...';
  String nextPrayerTime = '--:--';

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_notification');
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

  Future<void> updatePrayerTimesByLocation() async {
    double lat = 21.4225; // إحداثيات مكة المكرمة (خطة بديلة)
    double lng = 39.8262;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        ).catchError((e) {
          return Future.value(Position(latitude: 21.4225, longitude: 39.8262, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0));
        });
        
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }

    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi;
    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, params);

    final nextPrayer = prayerTimes.nextPrayer();
    DateTime nextTime = DateTime.now();
    String name = 'الصلاة القادمة';

    if (nextPrayer == Prayer.fajr) { name = 'الفجر'; nextTime = prayerTimes.fajr; }
    else if (nextPrayer == Prayer.sunrise) { name = 'الشروق'; nextTime = prayerTimes.sunrise; }
    else if (nextPrayer == Prayer.dhuhr) { name = 'الظهر'; nextTime = prayerTimes.dhuhr; }
    else if (nextPrayer == Prayer.asr) { name = 'العصر'; nextTime = prayerTimes.asr; }
    else if (nextPrayer == Prayer.maghrib) { name = 'المغرب'; nextTime = prayerTimes.maghrib; }
    else if (nextPrayer == Prayer.isha) { name = 'العشاء'; nextTime = prayerTimes.isha; }

    final timeFormat = DateFormat('hh:mm a', 'ar');
    
    nextPrayerName = name;
    nextPrayerTime = timeFormat.format(nextTime);

    final hijri = HijriCalendar.fromDate(DateTime.now());
    final hijriDate = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

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

    await showPersistentPrayerNotification(name, nextPrayerTime, hijriDate, schedule);
  }

  Future<void> showWelcomeNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'welcome_channel', 'إشعارات الترحيب',
      channelDescription: 'إشعار عند فتح التطبيق',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF155E35),
      icon: '@drawable/ic_notification',
    );
    await flutterLocalNotificationsPlugin.show(
      0, 'أهلاً بك في نور المعرفة 🌙', 'نسأل الله أن ينفعك بما تقرأ وتتعلم.', const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showPersistentPrayerNotification(String nextPrayer, String time, String hijriDate, String schedule) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_channel', 'مواقيت الصلاة',
      channelDescription: 'إشعار دائم بمواقيت الصلاة والتاريخ الهجري',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      onlyAlertOnce: true,
      color: const Color(0xFF155E35),
      icon: '@drawable/ic_notification',
      styleInformation: BigTextStyleInformation(
        schedule,
        contentTitle: '$hijriDate\n🕌 $nextPrayer ($time)',
        summaryText: 'تطبيق نور المعرفة',
      ),
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
      icon: '@drawable/ic_notification',
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
