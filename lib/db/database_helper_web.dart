import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  // رابط موقعك على Cloudflare
  final String baseUrl = "https://noor-almaarifa-static2.bilalimhamad051.workers.dev";
  
  // كاش عشان مننزلش ملف القرآن الضخم كل مرة
  static List<dynamic>? _cachedVerses; 

  Future<void> init() async {}
  
  Future<List<Map<String, Object?>>> getSurahs() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/data/surahs.json'));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return List<Map<String, Object?>>.from(data['surahs'].map((e) => Map<String, Object?>.from(e)));
      }
    } catch (e) {}
    return [];
  }

  Future<List<Map<String, Object?>>> getSurah(int id) async {
    final surahs = await getSurahs();
    return surahs.where((s) => s['id'] == id).toList();
  }

  Future<List<Map<String, Object?>>> getVerses(int surahId) async {
    try {
      if (_cachedVerses == null) {
        final res = await http.get(Uri.parse('$baseUrl/data/quran_offline.json'));
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          _cachedVerses = data['verses'] as List;
        }
      }
      if (_cachedVerses != null) {
        return _cachedVerses!
            .where((v) => v['surah_id'] == surahId)
            .map((v) => Map<String, Object?>.from(v))
            .toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    final verses = await getVerses(surahId);
    return verses.where((v) => v['verse_number'] == verseNumber).toList();
  }

  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async {
    final bookKeys = ['muyassar', 'jalalayn', 'ibn_kathir', 'saadi', 'qurtubi', 'baghawy'];
    final List<Map<String, Object?>> results = [];
    
    // سحب التفاسير من الملفات المقسمة على Cloudflare
    for (var key in bookKeys) {
      try {
        final res = await http.get(Uri.parse('$baseUrl/data/tafsirs/$key/$surahId.json'));
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          if (data[verseNumber.toString()] != null) {
            results.add({
              'book_key': key,
              'text_ar': data[verseNumber.toString()]
            });
          }
        }
      } catch (e) {}
    }
    return results;
  }

  Future<List<Map<String, Object?>>> getTafsirBooks() async {
    return [
      {'key': 'muyassar', 'name_ar': 'التفسير الميسر'},
      {'key': 'ibn_kathir', 'name_ar': 'تفسير ابن كثير'},
      {'key': 'saadi', 'name_ar': 'تفسير السعدي'},
      {'key': 'qurtubi', 'name_ar': 'تفسير القرطبي'},
      {'key': 'baghawy', 'name_ar': 'تفسير البغوي'},
      {'key': 'jalalayn', 'name_ar': 'تفسير الجلالين'},
    ];
  }

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async {
    try {
      if (_cachedVerses == null) {
        final res = await http.get(Uri.parse('$baseUrl/data/quran_offline.json'));
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          _cachedVerses = data['verses'] as List;
        }
      }
      if (_cachedVerses != null) {
        final q = query.toLowerCase();
        return _cachedVerses!
            .where((v) => (v['text_simple'] ?? v['text_ar']).toString().contains(q))
            .take(limit)
            .map((v) => Map<String, Object?>.from(v))
            .toList();
      }
    } catch (e) {}
    return [];
  }
}
