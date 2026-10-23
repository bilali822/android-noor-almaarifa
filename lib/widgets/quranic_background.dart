import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية العاجية الأساسية
        Container(color: AppColors.bgDeep),
        
        // الآيات بخط عثماني كعلامة مائية
        Positioned(
          top: 40,
          right: -30,
          child: Transform.rotate(
            angle: -0.15, // ميل خفيف جداً
            child: Text(
              'وَنُنَزِّلُ مِنَ الْقُرْآنِ\nمَا هُوَ شِفَاءٌ وَرَحْمَةٌ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: 45,
                color: AppColors.primary.withOpacity(0.04), // شفافية عالية جداً
                height: 2.0,
              ),
            ),
          ),
        ),
        
        Positioned(
          bottom: 100,
          left: -20,
          child: Transform.rotate(
            angle: 0.1,
            child: Text(
              'إِنَّ هَذَا الْقُرْآنَ\nيَهْدِي لِلَّتِي هِيَ أَقْوَمُ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: 45,
                color: AppColors.primary.withOpacity(0.04),
                height: 2.0,
              ),
            ),
          ),
        ),

        // المحتوى
        child,
      ],
    );
  }
}
