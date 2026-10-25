import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/arabic_normalizer.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final docs = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docs.path, 'noor_quran.db');

    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/noor_quran.db');
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(
      dbPath,
      readOnly: true,
      singleInstance: true,
      onConfigure: (db) async {
        await db.execute('PRAGMA cache_size = 10000');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_hadiths_book ON hadiths(book)');
        await db.execute('PRAGMA temp_store = MEMORY');
      },
    );
  }

  // ═══ دوال القرآن ═══
  Future<List<Map<String, Object?>>> getSurahs() async => (await db).query('surahs', orderBy: 'id ASC');
  Future<List<Map<String, Object?>>> getSurah(int id) async => (await db).query('surahs', where: 'id = ?', whereArgs: [id], limit: 1);
  Future<List<Map<String, Object?>>> getVerses(int surahId) async => (await db).query('verses', where: 'surah_id = ?', whereArgs: [surahId], orderBy: 'verse_number ASC');
  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async => (await db).query('verses', where: 'surah_id = ? AND verse_number = ?', whereArgs: [surahId, verseNumber], limit: 1);
  
  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async => (await db).query('tafsirs', where: 'surah_id = ? AND verse_number = ?', whereArgs: [surahId, verseNumber]);
  Future<List<Map<String, Object?>>> getTafsirBooks() async => (await db).query('tafsir_books');
  
  Future<List<Map<String, Object?>>> getTafsirBooksForVerse(int surahId, int verseNumber) async {
    final d = await db;
    return d.rawQuery('''
      SELECT b.key, b.name_ar
      FROM tafsir_books b
      WHERE EXISTS (
        SELECT 1 FROM tafsirs t
        WHERE t.book_key = b.key
          AND t.surah_id = ?
          AND t.verse_number = ?
      )
      ORDER BY b.key
    ''', [surahId, verseNumber]);
  }

  // 🌟 دالة البحث الذكية (تتجاهل الحركات)
  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async {
    final d = await db;
    final normalizedQuery = ArabicNormalizer.normalize(query);
    return d.rawQuery('''
      SELECT verses.*, surahs.name_ar as surah_name
      FROM verses
      JOIN surahs ON verses.surah_id = surahs.id
      WHERE verses.text_simple LIKE ?
      LIMIT ?
    ''', ['%$normalizedQuery%', limit]);
  }


  // 🌟 جلب آيات صفحة معينة (للمصحف)
  Future<List<Map<String, Object?>>> getVersesByPage(int pageNumber) async {
    final d = await db;
    return d.rawQuery('''
      SELECT verses.*, surahs.name_ar as surah_name
      FROM verses
      JOIN surahs ON verses.surah_id = surahs.id
      WHERE verses.page_number = ?
      ORDER BY verses.surah_id ASC, verses.verse_number ASC
    ''', [pageNumber]);
  }

  // 🌟 جلب رقم الصفحة الأولى لسورة معينة (عند اختيار السورة)
  Future<int> getSurahStartPage(int surahId) async {
    final d = await db;
    final res = await d.rawQuery('SELECT page_number FROM verses WHERE surah_id = ? ORDER BY verse_number ASC LIMIT 1', [surahId]);
    if (res.isNotEmpty) return (res.first['page_number'] as int?) ?? 1;
    return 1;
  }

  // ═══ دوال الحديث ═══
  Future<List<Map<String, Object?>>> getHadiths() async => (await db).query('hadiths', orderBy: 'id ASC');

  Future<List<Map<String, Object?>>> getHadithsPaginated(int limit, {int? lastId}) async {
    final d = await db;
    if (lastId == null) {
      // أول 20 حديثاً
      return d.query('hadiths', orderBy: 'id ASC', limit: limit);
    } else {
      // الأحاديث التي تأتي بعد آخر ID تم تحميله
      return d.query('hadiths', where: 'id > ?', whereArgs: [lastId], orderBy: 'id ASC', limit: limit);
    }
  }

  Future<List<Map<String, Object?>>> getHadithBooks() async {
    final d = await db;
    final res = await d.rawQuery('SELECT DISTINCT book FROM hadiths');
    return res.map((row) => {'name': row['book']}).toList();
  }

  Future<List<Map<String, Object?>>> getHadithsByBook(String book) async {
    final d = await db;
    return d.query('hadiths', where: 'book = ?', whereArgs: [book], orderBy: 'hadith_number ASC');
  }

  Future<List<Map<String, Object?>>> searchHadiths(String query) async {
    final d = await db;
    if (int.tryParse(query) != null) {
      final number = int.parse(query);
      final results = await d.rawQuery(
        'SELECT * FROM hadiths WHERE hadith_number = ? OR arabic_text LIKE ?',
        [number, '%$query%']
      );
      if (results.isNotEmpty) return results;
    }
    return d.rawQuery(
      'SELECT * FROM hadiths WHERE arabic_text LIKE ? OR narrator LIKE ?',
      ['%$query%', '%$query%']
    );
  }
}
