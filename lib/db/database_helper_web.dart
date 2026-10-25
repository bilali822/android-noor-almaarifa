import '../utils/arabic_normalizer.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}

  Future<List<Map<String, Object?>>> getSurahs() async {
    return [
      {'id':1,'name_ar':'الفاتحة','verses_count':7}, {'id':2,'name_ar':'البقرة','verses_count':286},
      {'id':112,'name_ar':'الإخلاص','verses_count':4}, {'id':113,'name_ar':'الفلق','verses_count':5},
      {'id':114,'name_ar':'الناس','verses_count':6},
    ];
  }

  Future<List<Map<String, Object?>>> getSurah(int id) async {
    final all = await getSurahs();
    return all.where((e) => e['id'] == id).toList();
  }

  Future<List<Map<String, Object?>>> getVerses(int surahId) async {
    if (surahId == 1) {
      return [
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 1, 'text_ar': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 2, 'text_ar': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 3, 'text_ar': 'الرَّحْمَٰنِ الرَّحِيمِ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 4, 'text_ar': 'مَالِكِ يَوْمِ الدِّينِ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 5, 'text_ar': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 6, 'text_ar': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 7, 'text_ar': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ'},
      ];
    }
    if (surahId == 112) {
      return [
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 1, 'text_ar': 'قُلْ هُوَ اللَّهُ أَحَدٌ'},
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 2, 'text_ar': 'اللَّهُ الصَّمَدُ'},
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 3, 'text_ar': 'لَمْ يَلِدْ وَلَمْ يُولَدْ'},
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 4, 'text_ar': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ'},
      ];
    }
    return [];
  }

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    final verses = await getVerses(surahId);
    return verses.where((v) => v['verse_number'] == verseNumber).toList();
  }

  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async {
    return [{'book_key': 'muyassar', 'text_ar': 'التفسير الميسر: هذا نص تجريبي للمعاينة على الويب.'}];
  }

  Future<List<Map<String, Object?>>> getTafsirBooks() async {
    return [{'key': 'muyassar', 'name_ar': 'التفسير الميسر'}];
  }

  Future<List<Map<String, Object?>>> getTafsirBooksForVerse(int surahId, int verseNumber) async {
    final all = await getTafsirs(surahId, verseNumber);
    if (all.isEmpty) return [];
    final allBooks = await getTafsirBooks();
    final available = all.map((t) => t['book_key']).toSet();
    return allBooks.where((b) => available.contains(b['key'])).toList();
  }

  // 🌟 دالة البحث الذكية للويب (تتجاهل الحركات)
  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async {
    final normalizedQuery = ArabicNormalizer.normalize(query);
    final all = await getVerses(1) + await getVerses(2) + await getVerses(112);
    return all.where((v) => ArabicNormalizer.normalize(v['text_ar'] as String).contains(normalizedQuery)).take(limit).toList();
  }

  Future<List<Map<String, Object?>>> getHadiths() async => [];
  Future<List<Map<String, Object?>>> getHadithsPaginated(int limit, int offset) async => [];
  Future<List<Map<String, Object?>>> getHadithBooks() async => [];
  Future<List<Map<String, Object?>>> getHadithsByBook(String book) async => [];
  Future<List<Map<String, Object?>>> searchHadiths(String query) async => [];
}
