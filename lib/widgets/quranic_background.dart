import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // الخلفية العاجية الأساسية
        Container(color: AppColors.bgDeep),
        
        // طبقة النصوص (محمية من النقر عشان متعطلش الأزرار)
        IgnorePointer(
          child: Stack(
            children: [
              // 1. أعلى اليمين (آية)
              _buildWatermark(
                text: '﴿ وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ ﴾',
                top: size.height * 0.05,
                right: -20,
                angle: -0.1,
                fontSize: 45,
              ),
              
              // 2. أعلى اليسار (حديث)
              _buildWatermark(
                text: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
                top: size.height * 0.2,
                left: -30,
                angle: 0.15,
                fontSize: 35,
              ),

              // 3. المنتصف اليمين (آية)
              _buildWatermark(
                text: '﴿ إِنَّ هَذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ ﴾',
                top: size.height * 0.45,
                right: -40,
                angle: 0.05,
                fontSize: 40,
              ),

              // 4. المنتصف اليسار (حديث)
              _buildWatermark(
                text: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا\nسَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
                top: size.height * 0.55,
                left: -20,
                angle: -0.15,
                fontSize: 28,
              ),

              // 5. أسفل اليمين (آية)
              _buildWatermark(
                text: '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾',
                bottom: size.height * 0.15,
                right: -10,
                angle: -0.05,
                fontSize: 38,
              ),

              // 6. أسفل اليسار (حديث)
              _buildWatermark(
                text: 'الدَّالُّ عَلَى الْخَيْرِ كَفَاعِلِهِ',
                bottom: size.height * 0.05,
                left: -10,
                angle: 0.1,
                fontSize: 32,
              ),

              // 7. في النص (آية)
              _buildWatermark(
                text: '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾',
                top: size.height * 0.3,
                left: size.width * 0.3,
                angle: 0.2,
                fontSize: 30,
              ),
            ],
          ),
        ),
        
        // المحتوى الأساسي (الكروت والأزرار)
        child,
      ],
    );
  }

  // دالة مساعدة لإنشاء العلامة المائية
  Widget _buildWatermark({
    required String text,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double angle,
    required double fontSize,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: fontSize,
            // 🌟 لون صلب تماماً بدون شفافية (Solid Light Gray)
            color: const Color(0xFFCBD5E1), 
            height: 2.0,
          ),
        ),
      ),
    );
  }
}
