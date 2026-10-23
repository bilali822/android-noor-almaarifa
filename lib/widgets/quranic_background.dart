import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. اللون الأساسي (بيج فاتح)
        Container(color: AppColors.bgDeep),
        
        // 2. النقشة الإسلامية (بدون شفافية - بلون بيج غامق يطابق التصميم)
        Positioned.fill(
          child: Image.asset(
            'assets/images/islamic_pattern.png',
            repeat: ImageRepeat.repeat,
            fit: BoxFit.none,
            // 🌟 هنا بنصبغ النقشة بلون "بيج غامق/ذهبي هادئ" عشان تطابق التصميم
            color: const Color(0xFFE8DCCB), // لون بيج غامق/ذهبي هادئ
            colorBlendMode: BlendMode.srcIn, // بيخلي الخطوط بس تاخد اللون ده
          ),
        ),
        
        // 3. المحتوى
        child,
      ],
    );
  }
}
