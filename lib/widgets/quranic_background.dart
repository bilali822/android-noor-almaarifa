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
        Positioned.fill(
          child: Opacity(
            opacity: 0.08,
            child: Image.asset(
              'assets/images/islamic_pattern.png',
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              color: AppColors.primary,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
