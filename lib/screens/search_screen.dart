import 'dart:async';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'verse_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, Object?>> _results = [];
  bool _searching = false;
  Timer? _debounce;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChange(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(q);
    });
  }

  Future<void> _search(String q) async {
    q = q.trim();
    if (q.isEmpty || q == _lastQuery) {
      if (q.isEmpty && mounted) {
        setState(() {
          _results = [];
          _lastQuery = '';
          _searching = false;
        });
      }
      return;
    }
    _lastQuery = q;

    if (mounted) setState(() => _searching = true);

    try {
      final results = await DatabaseHelper.instance.searchVerses(q, limit: 200);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12122E),
        elevation: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChange,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'ابحث في الآيات...',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _searching
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _lastQuery.isEmpty ? Icons.search : Icons.info_outline,
                        size: 64,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _lastQuery.isEmpty
                            ? 'اكتب كلمة للبحث'
                            : 'لا توجد نتائج لـ "$_lastQuery"',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _results.length,
                  cacheExtent: 800,
                  itemBuilder: (context, i) {
                    final r = _results[i];
                    final sid = r['surah_id'] as int;
                    final vn = r['verse_number'] as int;
                    final text = r['text_ar'] as String? ?? '';

                    return Card(
                      color: const Color(0xFF12122E),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        onTap: () async {
                          final s = await DatabaseHelper.instance.getSurah(sid);
                          if (!mounted || s.isEmpty) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VerseScreen(
                                surahId: sid,
                                surahName: s.first['name_ar'] as String,
                                verseNumber: vn,
                                verseText: text,
                              ),
                            ),
                          );
                        },
                        title: Text(
                          '$sid:$vn',
                          style: const TextStyle(
                            color: Color(0xFF8B83FF),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            text.length > 140
                                ? '${text.substring(0, 140)}...'
                                : text,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.7,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
