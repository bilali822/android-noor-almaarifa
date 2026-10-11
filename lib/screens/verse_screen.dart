import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class VerseScreen extends StatefulWidget {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String verseText;

  const VerseScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
  });

  @override
  State<VerseScreen> createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen> {
  List<Map<String, Object?>> _tafsirs = [];
  Map<String, String> _bookNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tafsirs = await DatabaseHelper.instance.getTafsirs(
      widget.surahId,
      widget.verseNumber,
    );
    final books = await DatabaseHelper.instance.getTafsirBooks();
    if (!mounted) return;
    setState(() {
      _tafsirs = tafsirs;
      _bookNames = {
        for (final b in books)
          b['key'] as String: b['name_ar'] as String,
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12122E),
        elevation: 0,
        title: Text(
          '${widget.surahName} — آية ${widget.verseNumber}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // بطاقة الآية
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.15),
                        const Color(0xFFFF6B9D).withOpacity(0.05),
                      ],
                    ),
                    border: Border(
                      right: BorderSide(
                        color: const Color(0xFF6C63FF),
                        width: 4,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '﴿ ${widget.verseText} ﴾',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 2.2,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // التفاسير
                ..._tafsirs.map((t) {
                  final key = t['book_key'] as String;
                  final name = _bookNames[key] ?? key;
                  final text = t['text_ar'] as String? ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12122E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              color: Color(0xFF6C63FF),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFF8B83FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        Text(
                          text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.9,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
