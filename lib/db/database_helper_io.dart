import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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

  /// 🌟 جلب كتب التفسير اللي عندها تفسير فعلي للآية المحددة فقط
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

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async {
    final d = await db;
    return d.rawQuery('''
      SELECT verses.*, surahs.name_ar as surah_name 
      FROM verses 
      JOIN surahs ON verses.surah_id = surahs.id 
      WHERE verses.text_simple LIKE ? 
      LIMIT ?
    ''', ['%$query%', limit]);
  }

  // ═══ دوال الحديث ═══
  Future<List<Map<String, Object?>>> getHadiths() async => (await db).query('hadiths', orderBy: 'book ASC, hadith_number ASC');

  Future<List<Map<String, Object?>>> getHadithBooks() async {
    final d = await db;
    final res = await d.rawQuery('SELECT DISTINCT book FROM hadiths');
    return res.map((row) => {'name': row['book']}).toList();
  }

  Future<List<Map<String, Object?>>> getHadithsByBook(String book) async {
    final d = await db;
    return d.query('hadiths', where: 'book = ?', whereArgs: [book], orderBy: 'hadith_number ASC');
  }

  // 🌟 دالة البحث الذكية في الأحاديث
  Future<List<Map<String, Object?>>> searchHadiths(String query) async {
    final d = await db;
    // لو المستخدم كتب رقم صافي، ابحث برقم الحديث أو نص فيه الرقم
    if (int.tryParse(query) != null) {
      final number = int.parse(query);
      final results = await d.rawQuery(
        'SELECT * FROM hadiths WHERE hadith_number = ? OR arabic_text LIKE ?',
        [number, '%$query%']
      );
      if (results.isNotEmpty) return results;
    }
    // بحث عادي في النص والراوي
    return d.rawQuery(
      'SELECT * FROM hadiths WHERE arabic_text LIKE ? OR narrator LIKE ?',
      ['%$query%', '%$query%']
    );
  }
}
