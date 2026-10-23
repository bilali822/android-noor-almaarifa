import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.bgDeep),
        // نقشة خفيفة جداً (نستخدم أيقونة مسجد مكررة بشكل شفاف)
        Positioned.fill(
          child: Opacity(
            opacity: 0.02,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, i) => const Icon(Icons.mosque, size: 100, color: AppColors.primary),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
