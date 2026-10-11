import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'verse_screen.dart';

class SurahScreen extends StatefulWidget {
  final int surahId;
  final String surahName;

  const SurahScreen({
    super.key,
    required this.surahId,
    required this.surahName,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  List<Map<String, Object?>> _verses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final verses = await DatabaseHelper.instance.getVerses(widget.surahId);
    if (!mounted) return;
    setState(() {
      _verses = verses;
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
          widget.surahName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _verses.length,
              cacheExtent: 1200,
              itemBuilder: (context, i) {
                final v = _verses[i];
                final vn = v['verse_number'] as int;
                final text = v['text_ar'] as String? ?? '';

                return Card(
                  color: const Color(0xFF12122E),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VerseScreen(
                            surahId: widget.surahId,
                            surahName: widget.surahName,
                            verseNumber: vn,
                            verseText: text,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // رقم الآية
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$vn',
                                style: const TextStyle(
                                  color: Color(0xFF8B83FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // النص
                          Text(
                            text,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 2.0,
                              fontFamily: 'serif',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // زر التفسير
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Icon(
                                Icons.menu_book,
                                color: Color(0xFF6C63FF),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'عرض التفسير',
                                style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
