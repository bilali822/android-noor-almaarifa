// قاعدة بيانات الويب (بيانات تجريبية لضمان عمل المعاينة)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}
  
  Future<List<Map<String, Object?>>> getSurahs() async => [];
  Future<List<Map<String, Object?>>> getSurah(int id) async => [];
  Future<List<Map<String, Object?>>> getVerses(int surahId) async => [];

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    // دايماً هيرجع آية الكرسي كبيانات تجريبية للويب
    return [
      {
        'surah_id': 2,
        'surah_name': 'البقرة',
        'verse_number': 255,
        'text_ar': 'اللَّهُ لَا إِلَـٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ'
      }
    ];
  }

  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async {
    return [
      {'book_key': 'muyassar', 'text_ar': 'التفسير الميسر: الله الذي لا يستحق الألوهية والعبودية إلا هو، الحيُّ الذي له جميع معاني الحياة الكاملة، القائم على كل شيء، لا تأخذه سِنَة ولا نوم...'}
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
