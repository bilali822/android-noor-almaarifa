import '../utils/arabic_normalizer.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}

  Future<List<Map<String, Object?>>> getSurahs() async => [
    {'id':1,'name_ar':'الفاتحة','verses_count':7}, {'id':2,'name_ar':'البقرة','verses_count':286},
    {'id':112,'name_ar':'الإخلاص','verses_count':4}, {'id':113,'name_ar':'الفلق','verses_count':5},
    {'id':114,'name_ar':'الناس','verses_count':6},
  ];

  Future<List<Map<String, Object?>>> getSurah(int id) async {
    return (await getSurahs()).where((e) => e['id'] == id).toList();
  }

  Future<List<Map<String, Object?>>> getVerses(int surahId) async {
    if (surahId == 1) {
      return [
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 1, 'text_ar': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 2, 'text_ar': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
      ];
    }
    if (surahId == 112) {
      return [
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 1, 'text_ar': 'قُلْ هُوَ اللَّهُ أَحَدٌ'},
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 2, 'text_ar': 'اللَّهُ الصَّمَدُ'},
      ];
    }
    return [];
  }

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    return (await getVerses(surahId)).where((v) => v['verse_number'] == verseNumber).toList();
  }

  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async => [{'book_key': 'muyassar', 'text_ar': 'التفسير الميسر: هذا نص تجريبي للمعاينة على الويب.'}];
  Future<List<Map<String, Object?>>> getTafsirBooks() async => [{'key': 'muyassar', 'name_ar': 'التفسير الميسر'}];
  
  Future<List<Map<String, Object?>>> getTafsirBooksForVerse(int surahId, int verseNumber) async {
    final all = await getTafsirs(surahId, verseNumber);
    if (all.isEmpty) return [];
    final allBooks = await getTafsirBooks();
    final available = all.map((t) => t['book_key']).toSet();
    return allBooks.where((b) => available.contains(b['key'])).toList();
  }

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async {
    final normalizedQuery = ArabicNormalizer.normalize(query);
    final all = await getVerses(1) + await getVerses(112);
    return all.where((v) => ArabicNormalizer.normalize(v['text_ar'] as String).contains(normalizedQuery)).take(limit).toList();
  }

  Future<List<Map<String, Object?>>> getHadiths() async => [
    {'id': 1, 'book': 'صحيح البخاري', 'hadith_number': 1, 'arabic_text': 'إنما الأعمال بالنيات...', 'narrator': 'عمر', 'grade': 'صحيح'},
    {'id': 2, 'book': 'صحيح البخاري', 'hadith_number': 2, 'arabic_text': 'بني الإسلام على خمس...', 'narrator': 'ابن عمر', 'grade': 'صحيح'},
    {'id': 3, 'book': 'صحيح مسلم', 'hadith_number': 1, 'arabic_text': 'الطهور شطر الإيمان...', 'narrator': 'أبو مالك', 'grade': 'صحيح'},
  ];
  
  Future<List<Map<String, Object?>>> getHadithsPaginated(int limit, int offset) async {
    final all = await getHadiths();
    if (offset >= all.length) return [];
    return all.skip(offset).take(limit).toList();
  }
  
  Future<List<Map<String, Object?>>> getHadithsByBookPaginated(String book, int limit, int offset) async {
    final all = (await getHadiths()).where((h) => h['book'] == book).toList();
    if (offset >= all.length) return [];
    return all.skip(offset).take(limit).toList();
  }

  Future<List<Map<String, Object?>>> getHadithBooks() async => [{'name': 'صحيح البخاري'}, {'name': 'صحيح مسلم'}];
  Future<List<Map<String, Object?>>> getHadithsByBook(String book) async => (await getHadiths()).where((h) => h['book'] == book).toList();
  Future<List<Map<String, Object?>>> searchHadiths(String query) async => (await getHadiths()).where((h) => (h['arabic_text'] as String).contains(query)).toList();
}
