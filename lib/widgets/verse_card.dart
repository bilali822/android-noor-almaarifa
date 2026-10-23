import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show FontFeature;
import '../theme/app_colors.dart';

class VerseCard extends StatelessWidget {
  final String surahName;
  final int verseNumber;
  final String text;
  final VoidCallback onTafsir;

  const VerseCard({
    super.key,
    required this.surahName,
    required this.verseNumber,
    required this.text,
    required this.onTafsir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سورة $surahName',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'آية $verseNumber',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // النص العثماني
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Text(
              '﴿ $text ﴾',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 24, 
                height: 2.4, // زيادة كبيرة في المسافة لاستيعاب الحركات
                fontFamily: 'AmiriQuran',
                letterSpacing: 1.5, // إضافة مسافة بين الحروف عشان الحركات متداخلش
                fontFeatures: [
                  FontFeature.enable('kern'),  // الكيرنينج
                  FontFeature.enable('liga'),  // توصيل الحروف
                  FontFeature.enable('calt'),  // البدائل السياقية
                  FontFeature.enable('mark'),  // ترتيب الحركات (مهم جداً)
                  FontFeature.enable('mkmk'),  // ترتيب الحركات فوق بعضها (مهم جداً)
                  FontFeature.enable('ss01'),  // البديل الأسلوبي 1
                ],
              ),
            ),
          ),
          
          const Divider(color: AppColors.border, height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '$text\n[سورة $surahName - آية $verseNumber]'));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الآية')));
                  },
                  icon: const Icon(Icons.copy, size: 18, color: AppColors.textMuted),
                  label: const Text('نسخ', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.border),
              Expanded(
                child: TextButton.icon(
                  onPressed: onTafsir,
                  icon: const Icon(Icons.menu_book, size: 18, color: AppColors.primary),
                  label: const Text('التفسير', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
