import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/verse_card.dart';
import '../widgets/tafsir_card.dart';

class TafsirViewScreen extends StatelessWidget {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String verseText;
  final List<Map<String, String>> tafsirList;

  const TafsirViewScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
    required this.tafsirList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        title: const Text('تفسير الآية', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // كارت الآية
          VerseCard(
            surahId: surahId,
            surahName: surahName,
            verseNumber: verseNumber,
            text: verseText,
            tafsirText: '', // فارغ عشان مانكررش التفسير
            onTafsir: () {}, // معطل
          ),
          
          // كروت التفاسير
          ...tafsirList.map((t) => TafsirCard(
            bookName: t['book_name'] ?? '',
            tafsirText: t['text'] ?? '',
          )),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
