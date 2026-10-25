import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class VerseCard extends StatelessWidget {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String text;
  final String tafsirText;
  final VoidCallback onTafsir;

  const VerseCard({
    super.key, 
    required this.surahId, 
    required this.surahName, 
    required this.verseNumber, 
    required this.text, 
    required this.tafsirText,
    required this.onTafsir,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final quranFontSize = (screenWidth * 0.065).clamp(20.0, 30.0);
    final tafsirFontSize = (screenWidth * 0.042).clamp(14.0, 18.0);

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
              Expanded(child: Text('سورة $surahName • آية $verseNumber', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))),
            ]),
          ),
          const Divider(color: AppColors.border, height: 1),

          // الآية (النص)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              '﴿ $text ﴾',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text, fontSize: quranFontSize, height: 2.2, fontFamily: 'UthmanicHafs'),
            ),
          ),
          
          // التفسير
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              tafsirText,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              maxLines: 5, // تحديد 5 سطور عشان الكارت ميطولش
              overflow: TextOverflow.ellipsis, // لو طال بيحط نقط
              style: TextStyle(color: AppColors.textSoft, fontSize: tafsirFontSize, height: 1.8, fontFamily: 'UthmanicHafs'),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // الأزرار (تحت خالص ومضمولة)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('نسخ', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary, 
                      side: const BorderSide(color: AppColors.primary), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                      padding: const EdgeInsets.symmetric(vertical: 10)
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTafsir, 
                    icon: const Icon(Icons.menu_book, size: 16),
                    label: const Text('تفسير', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary, 
                      side: const BorderSide(color: AppColors.primary), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                      padding: const EdgeInsets.symmetric(vertical: 10)
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
