// نسخة وهمية (للويب فقط) عشان المتصفح يقدر يبني التطبيق بدون أخطاء
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}
  
  Future<List<Map<String, Object?>>> getSurahs() async => [];
  Future<List<Map<String, Object?>>> getSurah(int id) async => [];
  Future<List<Map<String, Object?>>> getVerses(int surahId) async => [];
  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async => [];
  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async => [];
  Future<List<Map<String, Object?>>> getTafsirBooks() async => [];
  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async => [];
}
