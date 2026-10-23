import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  final _fatihaVerses = [
    {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 1, 'text_ar': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'},
    {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 2, 'text_ar': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
    {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 3, 'text_ar': 'الرَّحْمَٰنِ الرَّحِيمِ'},
    {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 4, 'text_ar': 'مَالِكِ يَوْمِ الدِّينِ'},
    {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 5, 'text_ar': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ'},
    {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 6, 'text_ar': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ'},
    {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 7, 'text_ar': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ'},
  ];

  Future<void> init() async {}
  
  Future<List<Map<String, Object?>>> getSurahs() async => [];
  Future<List<Map<String, Object?>>> getSurah(int id) async => [];

  Future<List<Map<String, Object?>>> getVerses(int surahId) async {
    if (surahId == 1) return _fatihaVerses;
    if (surahId == 2) {
      return [
        {'surah_id': 2, 'surah_name': 'البقرة', 'verse_number': 1, 'text_ar': 'الم'},
        {'surah_id': 2, 'surah_name': 'البقرة', 'verse_number': 2, 'text_ar': 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ'},
        {'surah_id': 2, 'surah_name': 'البقرة', 'verse_number': 255, 'text_ar': 'اللَّهُ لَا إِلَـٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ'},
      ];
    }
    return [];
  }

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    final verses = await getVerses(surahId);
    return verses.where((v) => v['verse_number'] == verseNumber).toList();
  }

  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async {
    return [
      {'book_key': 'muyassar', 'text_ar': 'التفسير الميسر: هذا النص هو تفسير تجريبي يظهر على نسخة الويب. لتجربة التفسير الحقيقي، يرجى تثبيت تطبيق الأندرويد.'}
    ];
  }

  Future<List<Map<String, Object?>>> getTafsirBooks() async {
    return [
      {'key': 'muyassar', 'name_ar': 'التفسير الميسر'},
      {'key': 'ibn_kathir', 'name_ar': 'تفسير ابن كثير'},
      {'key': 'saadi', 'name_ar': 'تفسير السعدي'},
    ];
  }

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async => [];
}
