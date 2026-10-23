import 'package:flutter/material.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // الخلفية الأساسية (البيج الفاتح من الصورة)
      color: const Color(0xFFF9F6F0), 
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            // تكرار الصورة
            image: const AssetImage('assets/images/islamic_pattern.png'),
            repeat: ImageRepeat.repeat,
            // حجم النقشة (كل ما الرقم يقل، النقشة تكبر)
            scale: 1.5, 
            // تلوين النقشة بالبيج الغامق/الذهبي اللي في الصورة
            colorFilter: const ColorFilter.mode(
              Color(0xFFEADBC8), 
              BlendMode.srcIn,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
