import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});
  final List<Map<String, String>> _adhkar = const [
    {'title': 'أذكار الصباح', 'text': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ...'},
    {'title': 'أذكار المساء', 'text': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ...'},
    {'title': 'أذكار النوم', 'text': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا...'},
    {'title': 'أذكار الاستيقاظ', 'text': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ.'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(backgroundColor: AppColors.bgDeep, title: const Text('الأذكار والأدعية', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), iconTheme: const IconThemeData(color: AppColors.primary)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16), itemCount: _adhkar.length,
        itemBuilder: (context, i) {
          final z = _adhkar[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Column(children: [
              Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(16))), child: Row(children: [const Icon(Icons.wb_sunny, color: Colors.white), const SizedBox(width: 8), Text(z['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))])),
              Padding(padding: const EdgeInsets.all(16), child: Text(z['text']!, textDirection: TextDirection.rtl, style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 20, height: 2.0, color: AppColors.text))),
            ]),
          );
        },
      ),
    );
  }
}
