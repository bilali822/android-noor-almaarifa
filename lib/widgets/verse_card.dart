import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class VerseCard extends StatelessWidget {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String text;
  final String tafsirText;

  const VerseCard({super.key, required this.surahId, required this.surahName, required this.verseNumber, required this.text, required this.tafsirText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الكارت
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Text('مساعد القرآن • سورة $surahName • الآية $verseNumber', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          ),
          
          // الآية
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text('﴿ $text ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 32, height: 2.0, fontFamily: 'UthmanicHafs')),
          ),
          
          // اسم السورة
          Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 16),
            child: Align(alignment: Alignment.centerRight, child: Text('سورة $surahName - الآية $verseNumber', style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
          ),
          
          // التفسير
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(tafsirText, textDirection: TextDirection.rtl, textAlign: TextAlign.justify, style: const TextStyle(color: AppColors.textSoft, fontSize: 14, height: 1.8)),
          ),
          
          const SizedBox(height: 16),
          
          // الأزرار
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { Clipboard.setData(ClipboardData(text: text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ'))); },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('نسخ'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {}, // فتح صفحة التفسير لو حبيت
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text('تفسير'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
