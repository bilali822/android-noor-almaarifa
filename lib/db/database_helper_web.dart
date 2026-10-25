import '../utils/arabic_normalizer.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}

  // إضافة بعض السور لكي تظهر في القائمة
  Future<List<Map<String, Object?>>> getSurahs() async {
    return [
      {'id': 1, 'name_ar': 'الفاتحة', 'verses_count': 7}, 
      {'id': 2, 'name_ar': 'البقرة', 'verses_count': 286},
      {'id': 114, 'name_ar': 'الناس', 'verses_count': 6}
    ];
  }

  Future<List<Map<String, Object?>>> getSurah(int id) async {
    final all = await getSurahs();
    return all.where((e) => e['id'] == id).toList();
  }

  // 🌟 بيانات تجريبية لعدة صفحات لتجربة التمرير
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
        {'surah_id': 2, 'surah_name': 'البقرة', 'verse_number': 3, 'text_ar': 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ'},
        {'surah_id': 2, 'surah_name': 'البقرة', 'verse_number': 4, 'text_ar': 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ'},
        {'surah_id': 2, 'surah_name': 'البقرة', 'verse_number': 5, 'text_ar': 'أُولَٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ'},
      ];
    }

    if (pageNumber == 604) {
      return [
        {'surah_id': 114, 'surah_name': 'الناس', 'verse_number': 1, 'text_ar': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ'},
        {'surah_id': 114, 'surah_name': 'الناس', 'verse_number': 2, 'text_ar': 'مَلِكِ النَّاسِ'},
        {'surah_id': 114, 'surah_name': 'الناس', 'verse_number': 3, 'text_ar': 'إِلَٰهِ النَّاسِ'},
        {'surah_id': 114, 'surah_name': 'الناس', 'verse_number': 4, 'text_ar': 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ'},
        {'surah_id': 114, 'surah_name': 'الناس', 'verse_number': 5, 'text_ar': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ'},
        {'surah_id': 114, 'surah_name': 'الناس', 'verse_number': 6, 'text_ar': 'مِنَ الْجِنَّةِ وَالنَّاسِ'},
      ];
    }
    return [];
  }

  Future<int> getSurahStartPage(int surahId) async {
    if (surahId == 1) return 1;
    if (surahId == 2) return 2;
    if (surahId == 114) return 604;
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

  // 🌟 الدوال الجديدة التي أضفناها للأحاديث لكي ينجح بناء الويب
  Future<List<Map<String, Object?>>> getHadiths() async => [];
  
  Future<List<Map<String, Object?>>> getHadithsPaginated(int limit, {int? lastId}) async => [];
  
  Future<List<Map<String, Object?>>> getHadithsByBookPaginated(String book, int limit, {int? lastId}) async => [];
  
  Future<List<Map<String, Object?>>> getHadithBooks() async => [];
  
  Future<List<Map<String, Object?>>> getHadithsByBook(String book) async => [];
  
  Future<List<Map<String, Object?>>> searchHadiths(String query) async => [];
}
