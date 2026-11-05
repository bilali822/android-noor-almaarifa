import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DeviceProfiler {
  static String performanceLevel = 'High'; // High, Medium, Low

  static Future<void> detectPerformance() async {
    if (kIsWeb) {
      performanceLevel = 'Medium';
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    performanceLevel = prefs.getString('performance_level') ?? 'High';
  }

  static bool get isHighEnd => performanceLevel == 'High';
  static bool get isMediumEnd => performanceLevel == 'Medium';
  static bool get isLowEnd => performanceLevel == 'Low';
}
