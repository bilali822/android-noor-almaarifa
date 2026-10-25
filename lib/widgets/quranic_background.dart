import 'package:flutter/material.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F6F0), // الخلفية البيج
      child: Stack(
        children: [
          // 1. رسم الآيات
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _VersesPainter(),
              ),
            ),
          ),
          
          // 2. المحتوى الأساسي (شيلنا تأثير التلاشي)
          child,
        ],
      ),
    );
  }
}

class _VersesPainter extends CustomPainter {
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
    // 🌟 لون واضح (شفافية 30% بدل 8%) وخط عريض
    final Color textColor = const Color(0xFF155E35).withOpacity(0.3); 
    const String fontFamily = 'UthmanicHafs';
    
    const double safeMargin = 30.0;

    final List<Offset> positions = [
      Offset(size.width * 0.8, size.height * 0.15),  
      Offset(size.width * 0.2, size.height * 0.25),  
      Offset(size.width * 0.85, size.height * 0.50), 
      Offset(size.width * 0.15, size.height * 0.60), 
      Offset(size.width * 0.75, size.height * 0.85), 
      Offset(size.width * 0.25, size.height * 0.90), 
    ];

    for (int i = 0; i < _verses.length; i++) {
      final double x = positions[i].dx.clamp(safeMargin, size.width - safeMargin);
      final double y = positions[i].dy.clamp(safeMargin, size.height - safeMargin);

      final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: _verses[i],
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: size.width * 0.055,
            color: textColor,
            height: 1.8,
            fontWeight: FontWeight.w600, // 🌟 خط أعرض
          ),
        ),
      );

      textPainter.layout(maxWidth: size.width * 0.7);

      canvas.save();
      canvas.translate(x, y);
      
      final double angle = (i % 2 == 0) ? -0.05 : 0.05;
      canvas.rotate(angle);

      textPainter.paint(
        canvas, 
        Offset(-textPainter.width / 2, -textPainter.height / 2)
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
