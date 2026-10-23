import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class VerseCard extends StatefulWidget {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String text;
  final VoidCallback onTafsir;

  const VerseCard({super.key, required this.surahId, required this.surahName, required this.verseNumber, required this.text, required this.onTafsir});

  @override State<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends State<VerseCard> {
  bool _isSaved = false;

  @override void initState() { super.initState(); _checkIfSaved(); }

  Future<void> _checkIfSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    setState(() => _isSaved = saved.contains('${widget.surahId}:${widget.verseNumber}'));
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    final key = '${widget.surahId}:${widget.verseNumber}';
    setState(() { if (_isSaved) { saved.remove(key); _isSaved = false; } else { saved.add(key); _isSaved = true; } });
    await prefs.setStringList('bookmarks', saved);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.menu_book, color: AppColors.primary, size: 16)),
            const SizedBox(width: 8),
            Text('مساعد القرآن • سورة ${widget.surahName} • الآية ${widget.verseNumber}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text('﴿ ${widget.text} ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 28, height: 2.2, fontFamily: 'UthmanicHafs')),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 24, bottom: 16),
          child: Align(alignment: Alignment.centerRight, child: Text('سورة ${widget.surahName} - الآية ${widget.verseNumber}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
        ),
        const Divider(color: AppColors.border, height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: widget.onTafsir, icon: const Icon(Icons.menu_book, size: 18), label: const Text('تفسير'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: () { Clipboard.setData(ClipboardData(text: '${widget.text}')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ'))); }, icon: const Icon(Icons.copy, size: 18), label: const Text('نسخ'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
          ]),
        )
      ]),
    );
  }
}
