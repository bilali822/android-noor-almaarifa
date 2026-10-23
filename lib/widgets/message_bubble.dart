import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        // 🌟 في نظام RTL: (start) يعني يمين، و (end) يعني شمال
        // رسالة المستخدم تروح يمين (start)، ورسالة الذكاء الاصطناعي تروح شمال (end)
        mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة الذكاء الاصطناعي (تظهر على شمال الفقاعة)
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary, // خلفية خضراء
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
          ],

          // الفقاعة نفسها
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.bgSurface, // المستخدم أخضر، الذكاء أبيض
                border: isUser ? null : Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  // الزاوية المدببة (الذيل) تروح يمين لو المستخدم، وشمال لو الذكاء
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    text,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.text, // النص أبيض لو المستخدم، رمادي لو الذكاء
                      fontSize: 15,
                      height: 1.8,
                      fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isUser ? Colors.white70 : AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
