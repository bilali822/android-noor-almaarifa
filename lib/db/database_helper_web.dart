// نسخة الويب (بيانات تجريبية للمعاينة)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}
  
  Future<List<Map<String, Object?>>> getSurahs() async => [];
  Future<List<Map<String, Object?>>> getSurah(int id) async => [];
  Future<List<Map<String, Object?>>> getVerses(int surahId) async => [];

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    return [
      {
        'surah_id': surahId,
        'surah_name': 'الكهف',
        'verse_number': verseNumber,
        'text_ar': 'أَمْ حَسِبْتَ أَنَّ أَصْحَابَ الْكَهْفِ وَالرَّقِيمِ كَانُوا مِنْ آيَاتِنَا عَجَبًا'
      }
    ];
  }

  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async {
    return [
      {'book_key': 'muyassar', 'text_ar': 'أَمْ حَسِبْتَ -أيها الرسول- أن قصة أصحاب الكهف والرقيم من آياتنا العجيبة؟ بل قدرتُنا على إحياء الموتى وبعثهم من القبور أعجب من ذلك.'}
    ];
  }

  Future<List<Map<String, Object?>>> getTafsirBooks() async {
    return [
      {'key': 'muyassar', 'name_ar': 'التفسير الميسر'},
    ];
  }

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async => [];
}
