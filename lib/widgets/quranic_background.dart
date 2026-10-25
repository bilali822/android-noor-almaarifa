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
          // 1. النقشة الهندسية والآيات (CustomPainter)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _IslamicPatternPainter(size: size),
              ),
            ),
          ),
          
          // 2. توهج ضوئي ذهبي فاخر في الأعلى (Ambient Gold Glow)
          Positioned(
            top: -120,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.12), // 🌟 لون ذهبي شفاف
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // توهج ذهبي خفيف في الزاوية السفلية اليسرى لتوازن الشاشة
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. زخارف ذهبية في الزوايا (مستوحاة من أطر المصاحف)
          Positioned(
            top: 10, left: 10, right: 10, bottom: 10,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // 4. محتوى التطبيق
          child,
        ],
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Size size;
  _IslamicPatternPainter({required this.size});

  final List<String> _verses = [
    '﴿ وَنُنَزِّلُ مِنَ الْقُرْآنِ\nمَا هُوَ شِفَاءٌ وَرَحْمَةٌ ﴾',
    'خَيْرُكُمْ مَنْ\nتَعَلَّمَ الْقُرْآنَ',
    '﴿ أَلَا بِذِكْرِ اللَّهِ\nتَطْمَئِنُّ الْقُلُوبُ ﴾',
    '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // --- أ. رسم النقشة الهندسية (شبكة نجوم) ---
    final patternPaint = Paint()
      ..color = const Color(0xFF155E35).withOpacity(0.03) // شفافية 3%
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double spacing = 60.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawEightPointedStar(canvas, Offset(x, y), 15, patternPaint);
      }
    }

    // --- ب. رسم الآيات كعلامة مائية ---
    final Color textColor = const Color(0xFF155E35).withOpacity(0.05); // شفافية 5%
    const String fontFamily = 'UthmanicHafs';

    final List<Offset> positions = [
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.35),
      Offset(size.width * 0.85, size.height * 0.60),
      Offset(size.width * 0.15, size.height * 0.85),
    ];

    for (int i = 0; i < _verses.length; i++) {
      final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: _verses[i],
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: size.width * 0.04,
            color: textColor,
            height: 1.8,
          ),
        ),
      );

      textPainter.layout(maxWidth: size.width * 0.4);

      canvas.save();
      canvas.translate(positions[i].dx, positions[i].dy);
      canvas.rotate((i % 2 == 0) ? -0.05 : 0.05);
      
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  // دالة رسم النجمة الثمانية الإسلامية
  void _drawEightPointedStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * 45 * (3.14159 / 180);
      double r = (i % 2 == 0) ? radius : radius * 0.5;
      double px = center.dx + r * _cos(angle);
      double py = center.dy + r * _sin(angle);
      if (i == 0) path.moveTo(px, py); else path.lineTo(px, py);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double angle) => [1.0, 0.707, 0.0, -0.707, -1.0, -0.707, 0.0, 0.707][(angle / 0.785).round() % 8];
  double _sin(double angle) => [0.0, 0.707, 1.0, 0.707, 0.0, -0.707, -1.0, -0.707][(angle / 0.785).round() % 8];

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
