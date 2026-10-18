import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              border: Border.all(color: AppColors.primary, width: 1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('جاري البحث', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(width: 12),
                ...List.generate(3, (i) => AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, _) {
                        final t = (_ctrl.value + i * 0.2) % 1.0;
                        final dy = (t < 0.5 ? -3 * (t * 2) : -3 * (2 - t * 2));
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Transform.translate(
                            offset: Offset(0, dy),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                          ),
                        );
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
