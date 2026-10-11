import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'surah_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, Object?>> _allSurahs = [];
  List<Map<String, Object?>> _filtered = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final surahs = await DatabaseHelper.instance.getSurahs();
    if (!mounted) return;
    setState(() {
      _allSurahs = surahs;
      _filtered = surahs;
      _loading = false;
    });
  }

  void _onSearch(String q) {
    q = q.trim();
    setState(() {
      _query = q;
      if (q.isEmpty) {
        _filtered = _allSurahs;
      } else {
        _filtered = _allSurahs.where((s) {
          final name = (s['name_ar'] as String? ?? '').toLowerCase();
          final id = s['id'].toString();
          return name.contains(q.toLowerCase()) || id == q;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12122E),
        elevation: 0,
        title: const Text(
          'نور المعرفة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : Column(
              children: [
                // صندوق البحث في السور
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: _onSearch,
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن سورة...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF6C63FF)),
                      filled: true,
                      fillColor: const Color(0xFF12122E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // قائمة السور (Lazy)
                Expanded(
                  child: ListView.builder(
                    itemCount: _filtered.length,
                    cacheExtent: 800,
                    itemBuilder: (context, i) {
                      final s = _filtered[i];
                      final id = s['id'] as int;
                      final name = s['name_ar'] as String? ?? '';
                      final count = s['verses_count'] as int? ?? 0;

                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurahScreen(
                                surahId: id,
                                surahName: name,
                              ),
                            ),
                          );
                        },
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$id',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '$count آية',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_left,
                          color: Colors.white38,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
