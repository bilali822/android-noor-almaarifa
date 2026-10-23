import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/verse_card.dart';
import '../widgets/tafsir_sheet.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('bookmarks') ?? [];
    List<Map<String, dynamic>> loaded = [];
    for (var item in saved) {
      final parts = item.split(':');
      if (parts.length == 2) {
        final sid = int.tryParse(parts[0]);
        final vn = int.tryParse(parts[1]);
        if (sid != null && vn != null) {
          final verse = await DatabaseHelper.instance.getVerse(sid, vn);
          if (verse.isNotEmpty) {
            loaded.add({
              'surahId': sid,
              'surahName': verse.first['surah_name'],
              'verseNumber': vn,
              'verseText': verse.first['text_ar'],
            });
          }
        }
      }
    }
    if (mounted) setState(() { _bookmarks = loaded; _isLoading = false; });
  }

  void _openTafsir(Map<String, dynamic> data) async {
    final books = await DatabaseHelper.instance.getTafsirBooks();
    if (!mounted) return;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => TafsirSheet(surahName: data['surahName'], surahId: data['surahId'], verseNumber: data['verseNumber'], verseText: data['verseText'], books: books));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(title: const Text('الآيات المحفوظة'), backgroundColor: Colors.transparent, elevation: 0),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : _bookmarks.isEmpty ? const Center(child: Text('لا توجد آيات محفوظة حتى الآن.', style: TextStyle(color: AppColors.textMuted, fontSize: 16))) : ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        itemCount: _bookmarks.length,
        itemBuilder: (context, i) {
          final v = _bookmarks[i];
          return VerseCard(surahId: v['surahId'], surahName: v['surahName'], verseNumber: v['verseNumber'], text: v['verseText'], onTafsir: () => _openTafsir(v));
        },
      ),
    );
  }
}
