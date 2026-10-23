import 'package:flutter/material.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: const Color(0xFFF9F6F0), // خلفية بيج فاتحة
      child: Stack(
        children: [
          // 1. الآيات والأحاديث (علامة مائية)
          IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: size.height * 0.1,
                  right: -20,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: const Text(
                      '﴿ وَنُنَزِّلُ مِنَ الْقُرْآنِ\nمَا هُوَ شِفَاءٌ وَرَحْمَةٌ ﴾',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 45, color: Color(0x1A155E35), height: 1.8),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.35,
                  left: -30,
                  child: Transform.rotate(
                    angle: 0.15,
                    child: const Text(
                      'خَيْرُكُمْ مَنْ\nتَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 35, color: Color(0x1A155E35), height: 1.8),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.25,
                  right: -30,
                  child: Transform.rotate(
                    angle: 0.05,
                    child: const Text(
                      '﴿ إِنَّ هَذَا الْقُرْآنَ\nيَهْدِي لِلَّتِي هِيَ أَقْوَمُ ﴾',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 45, color: Color(0x1A155E35), height: 1.8),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.05,
                  left: -20,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: const Text(
                      '﴿ أَلَا بِذِكْرِ اللَّهِ\nتَطْمَئِنُّ الْقُلُوبُ ﴾',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 40, color: Color(0x1A155E35), height: 1.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 2. المحتوى
          child,
        ],
      ),
    );
  }
}
