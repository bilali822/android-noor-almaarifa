import 'package:flutter/material.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 1. الخلفية البيج الفاتحة
        Container(color: const Color(0xFFF9F6F0)),

        // 2. الآيات والأحاديث في الخلفية (بشكل فني)
        IgnorePointer(
          child: Stack(
            children: [
              // آية أعلى اليمين
              Positioned(
                top: size.height * 0.08,
                right: -40,
                child: Transform.rotate(
                  angle: -0.05,
                  child: const Text(
                    '﴿ وَنُنَزِّلُ مِنَ الْقُرْآنِ\nمَا هُوَ شِفَاءٌ وَرَحْمَةٌ ﴾',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'UthmanicHafs',
                      fontSize: 55,
                      color: Color(0xFFF0E6D8), // لون بيج هادئ جداً
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              
              // حديث أعلى اليسار
              Positioned(
                top: size.height * 0.28,
                left: -30,
                child: Transform.rotate(
                  angle: 0.08,
                  child: const Text(
                    'خَيْرُكُمْ مَنْ تَعَلَّمَ\nالْقُرْآنَ وَعَلَّمَهُ',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'UthmanicHafs',
                      fontSize: 45,
                      color: Color(0xFFF0E6D8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              // آية في المنتصف
              Positioned(
                top: size.height * 0.50,
                right: -20,
                child: Transform.rotate(
                  angle: -0.03,
                  child: const Text(
                    '﴿ إِنَّ هَذَا الْقُرْآنَ\nيَهْدِي لِلَّتِي هِيَ أَقْوَمُ ﴾',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'UthmanicHafs',
                      fontSize: 50,
                      color: Color(0xFFF0E6D8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              // حديث أسفل اليسار
              Positioned(
                bottom: size.height * 0.25,
                left: -40,
                child: Transform.rotate(
                  angle: 0.05,
                  child: const Text(
                    'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ\nفِيهِ عِلْمًا سَهَّلَ اللَّهُ\nلَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'UthmanicHafs',
                      fontSize: 38,
                      color: Color(0xFFF0E6D8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              // آية أسفل اليمين
              Positioned(
                bottom: size.height * 0.05,
                right: -30,
                child: Transform.rotate(
                  angle: -0.08,
                  child: const Text(
                    '﴿ أَلَا بِذِكْرِ اللَّهِ\nتَطْمَئِنُّ الْقُلُوبُ ﴾',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'UthmanicHafs',
                      fontSize: 45,
                      color: Color(0xFFF0E6D8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. المحتوى الأساسي
        child,
      ],
    );
  }
}
