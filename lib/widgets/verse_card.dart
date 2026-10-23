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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الكارت
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Text('مساعد القرآن • $surahName • آية $verseNumber', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          ),
          
          // نص الآية (خط عثماني - حجم مناسب)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('﴿ $text ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 24, height: 2.2, fontFamily: 'UthmanicHafs')),
          ),
          
          // اسم السورة
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: Align(alignment: Alignment.centerRight, child: Text('سورة $surahName - الآية $verseNumber', style: const TextStyle(color: AppColors.textMuted, fontSize: 11))),
          ),
          
          const Divider(color: AppColors.border, height: 1),
          
          // التفسير (محدود بمساحة عشان ميكبرش)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120), // أقصى ارتفاع للتفسير
              child: SingleChildScrollView(
                child: Text(tafsirText, textDirection: TextDirection.rtl, textAlign: TextAlign.justify, style: const TextStyle(color: AppColors.textSoft, fontSize: 14, height: 1.8)),
              ),
            ),
          ),
          
          // الأزرار
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { Clipboard.setData(ClipboardData(text: text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ'))); },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('نسخ', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.menu_book, size: 16),
                  label: const Text('تفسير', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
