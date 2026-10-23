class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}
  
  Future<List<Map<String, Object?>>> getSurahs() async => [];
  Future<List<Map<String, Object?>>> getSurah(int id) async => [];

  Future<List<Map<String, Object?>>> getVerses(int surahId) async {
    if (surahId == 1) {
      return [
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 1, 'text_ar': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 2, 'text_ar': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
      ];
    }
    if (surahId == 2) {
      return [
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
      {'book_key': 'muyassar', 'text_ar': 'التفسير الميسر: الله الذي لا يستحق الألوهية والعبودية إلا هو، الحيُّ الذي له جميع معاني الحياة الكاملة، القائم على كل شيء.'},
      {'book_key': 'ibn_kathir', 'text_ar': 'تفسير ابن كثير: هذه الآية الكريمة أعظم آيات القرآن، وهي مشتملة على عشر جمل مستقلة.'},
    ];
  }

  Future<List<Map<String, Object?>>> getTafsirBooks() async {
    return [
      {'key': 'muyassar', 'name_ar': 'التفسير الميسر'},
      {'key': 'ibn_kathir', 'name_ar': 'تفسير ابن كثير'},
    ];
  }

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async => [];
}
