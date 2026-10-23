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
      // ⚡ تحسينات SQLite للأداء
      onConfigure: (db) async {
        await db.execute('PRAGMA cache_size = 10000');
        await db.execute('PRAGMA temp_store = MEMORY');
      },
    );
  }

  Future<List<Map<String, Object?>>> getSurahs() async => (await db).query('surahs', orderBy: 'id ASC');
  Future<List<Map<String, Object?>>> getSurah(int id) async => (await db).query('surahs', where: 'id = ?', whereArgs: [id], limit: 1);
  Future<List<Map<String, Object?>>> getVerses(int surahId) async => (await db).query('verses', where: 'surah_id = ?', whereArgs: [surahId], orderBy: 'verse_number ASC');
  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async => (await db).query('verses', where: 'surah_id = ? AND verse_number = ?', whereArgs: [surahId, verseNumber], limit: 1);
  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async => (await db).query('tafsirs', where: 'surah_id = ? AND verse_number = ?', whereArgs: [surahId, verseNumber]);
  Future<List<Map<String, Object?>>> getTafsirBooks() async => (await db).query('tafsir_books');
  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async => (await db).query('verses', where: 'text_simple LIKE ?', whereArgs: ['%$query%'], limit: limit);
}
