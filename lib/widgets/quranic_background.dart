import 'package:flutter/material.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: const Color(0xFFF9F6F0), // لون البيج
      child: Stack(
        children: [
          // 1. رسم الآيات كعلامة مائية (Watermark) ناعمة
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _WatermarkPainter(size: size),
              ),
            ),
          ),
          
          // 2. طبقة تدرج أبيض (لإبراز الكروت فوق الخلفية)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.6), // أبيض شفاف في المنتصف
                    Colors.transparent, // شفاف في الأطراف
                  ],
                  radius: 0.8,
                  center: Alignment.center,
                ),
              ),
            ),
          ),

          // 3. محتوى التطبيق
          child,
        ],
      ),
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final Size size;
  _WatermarkPainter({required this.size});

  final List<String> _verses = [
    '﴿ وَنُنَزِّلُ مِنَ الْقُرْآنِ\nمَا هُوَ شِفَاءٌ وَرَحْمَةٌ ﴾',
    'خَيْرُكُمْ مَنْ\nتَعَلَّمَ الْقُرْآنَ',
    '﴿ أَلَا بِذِكْرِ اللَّهِ\nتَطْمَئِنُّ الْقُلُوبُ ﴾',
    '﴿ إِنَّ هَذَا الْقُرْآنَ\nيَهْدِي لِلَّتِي هِيَ أَقْوَمُ ﴾',
    'مَنْ سَلَكَ طَرِيقًا\nيَلْتَمِسُ فِيهِ عِلْمًا',
    '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 🌟 تقليل الشفافية بشكل كبير جداً (4%)
    final Color textColor = const Color(0xFF155E35).withOpacity(0.04);
    const String fontFamily = 'UthmanicHafs';

    // توزيع الآيات على الأطراف لتجنب المنتصف
    final List<Offset> positions = [
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.50),
      Offset(size.width * 0.15, size.height * 0.65),
      Offset(size.width * 0.85, size.height * 0.85),
      Offset(size.width * 0.15, size.height * 0.90),
    ];

    for (int i = 0; i < _verses.length; i++) {
      final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: _verses[i],
          style: TextStyle(
            fontFamily: fontFamily,
            // 🌟 تصغير حجم الخط ليكون 3.5% من عرض الشاشة فقط
            fontSize: size.width * 0.035, 
            color: textColor,
            height: 1.8,
          ),
        ),
      );

      textPainter.layout(maxWidth: size.width * 0.4);

      canvas.save();
      canvas.translate(positions[i].dx, positions[i].dy);

      // زاوية خفيفة جداً
      final double angle = (i % 2 == 0) ? -0.05 : 0.05;
      canvas.rotate(angle);

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
