// نسخة الويب (بيانات تجريبية للمعاينة)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}
  
  Future<List<Map<String, Object?>>> getSurahs() async {
    return [
      {'id': 1, 'name_ar': 'الفاتحة', 'verses_count': 7},
      {'id': 2, 'name_ar': 'البقرة', 'verses_count': 286},
      {'id': 112, 'name_ar': 'الإخلاص', 'verses_count': 4},
    ];
  }
  
  Future<List<Map<String, Object?>>> getSurah(int id) async => [];
  
  Future<List<Map<String, Object?>>> getVerses(int surahId) async => [];

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    if (surahId == 2 && verseNumber == 255) {
      return [
        {
          'surah_id': 2,
          'surah_name': 'البقرة',
          'verse_number': 255,
          'text_ar': 'اللَّهُ لَا إِلَـٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ'
        }
      ];
    }
    return [
      {'surah_id': surahId, 'surah_name': 'تجريبي', 'verse_number': verseNumber, 'text_ar': 'هذه نسخة الويب للمعاينة فقط. قم بتثبيت الـ APK للحصول على قاعدة البيانات كاملة.'}
    ];
  }

  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async {
    return [
      {'book_key': 'muyassar', 'text_ar': 'الله الذي لا يستحق الألوهية والعبودية إلا هو، الحيُّ الذي له جميع معاني الحياة الكاملة، القائم على كل شيء... (تفسير تجريبي للويب)'}
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
