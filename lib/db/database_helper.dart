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

    // انسخ من assets أول مرة فقط
    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/noor_quran.db');
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(
      dbPath,
      readOnly: true,
      singleInstance: true,
    );
  }

  Future<List<Map<String, Object?>>> getSurahs() async {
    final d = await db;
    return d.query('surahs', orderBy: 'id ASC');
  }

  Future<List<Map<String, Object?>>> getSurah(int id) async {
    final d = await db;
    return d.query('surahs', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  Future<List<Map<String, Object?>>> getVerses(int surahId) async {
    final d = await db;
    return d.query(
      'verses',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'verse_number ASC',
    );
  }

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    final d = await db;
    return d.query(
      'verses',
      where: 'surah_id = ? AND verse_number = ?',
      whereArgs: [surahId, verseNumber],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async {
    final d = await db;
    return d.query(
      'tafsirs',
      where: 'surah_id = ? AND verse_number = ?',
      whereArgs: [surahId, verseNumber],
    );
  }

  Future<List<Map<String, Object?>>> getTafsirBooks() async {
    final d = await db;
    return d.query('tafsir_books');
  }

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async {
    final d = await db;
    return d.query(
      'verses',
      where: 'text_simple LIKE ?',
      whereArgs: ['%$query%'],
      limit: limit,
    );
  }
}
