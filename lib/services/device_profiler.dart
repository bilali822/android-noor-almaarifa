import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DeviceProfiler {
  static String performanceLevel = 'High';

  static Future<void> detectPerformance() async {
    if (kIsWeb) {
      performanceLevel = 'Medium';
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    performanceLevel = prefs.getString('performance_level') ?? 'High';
  }

  static bool get isLowEnd => performanceLevel == 'Low';
  static bool get isHighEnd => performanceLevel == 'High';
}
