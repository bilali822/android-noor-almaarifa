import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DeviceProfiler {
  static String performanceLevel = 'High'; // High, Medium, Low

  static Future<void> detectPerformance() async {
    // الويب دائماً متوسط الأداء لتجنب التعليق
    if (kIsWeb) {
      performanceLevel = 'Medium';
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    // إذا كان المستخدم قد اختار يدوياً، نحترم اختياره
    if (prefs.getString('performance_level') != null) {
      performanceLevel = prefs.getString('performance_level')!;
      return;
    }

    final deviceInfo = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfo.androidInfo;
      // فحص الرام (RAM) التقريبي بناءً على إصدار الأندرويد (طريقة تقريبية)
      // أو استخدام system_info لو أردت دقة أعلى
      int sdkInt = androidInfo.version.sdkInt;
      
      // إذا كان الإصدار قديماً (أقل من أندرويد 9) فهو غالباً جهاز ضعيف
      if (sdkInt < 28) {
        performanceLevel = 'Low';
      } else if (sdkInt < 31) {
        performanceLevel = 'Medium';
      } else {
        performanceLevel = 'High';
      }
    } catch (e) {
      performanceLevel = 'Medium'; // افتراضي
    }
    
    await prefs.setString('performance_level', performanceLevel);
  }

  static bool get isLowEnd => performanceLevel == 'Low';
  static bool get isHighEnd => performanceLevel == 'High';
}
