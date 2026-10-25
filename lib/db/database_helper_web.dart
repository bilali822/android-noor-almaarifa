import '../utils/arabic_normalizer.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}

  Future<List<Map<String, Object?>>> getSurahs() async {
    return [{'id':1,'name_ar':'الفاتحة','verses_count':7}, {'id':2,'name_ar':'البقرة','verses_count':286}];
  }

  Future<List<Map<String, Object?>>> getSurah(int id) async {
    final all = await getSurahs();
    return all.where((e) => e['id'] == id).toList();
  }

  Future<List<Map<String, Object?>>> getVersesByPage(int pageNumber) async {
    if (pageNumber == 1) {
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
    if (pageNumber == 2) {
      return [
        {'surah_id': 2, 'surah_name': 'البقرة', 'verse_number': 1, 'text_ar': 'الم'},
        {'surah_id': 2, 'surah_name': 'البقرة', 'verse_number': 2, 'text_ar': 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ'},
      ];
    }
    return []; 
  }

  Future<int> getSurahStartPage(int surahId) async {
    if (surahId == 1) return 1;
    if (surahId == 2) return 2;
    return 1;
  }

  Future<List<Map<String, Object?>>> getVerses(int surahId) async {
    final all = await getVersesByPage(1);
    return all.where((v) => v['surah_id'] == surahId).toList();
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

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async {
    return [];
  }

  Future<List<Map<String, Object?>>> getHadiths() async => [];
  Future<List<Map<String, Object?>>> getHadithsPaginated(int limit, int offset) async => [];
  Future<List<Map<String, Object?>>> getHadithBooks() async => [];
  Future<List<Map<String, Object?>>> getHadithsByBook(String book) async => [];
  Future<List<Map<String, Object?>>> searchHadiths(String query) async => [];
}
