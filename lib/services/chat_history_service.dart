import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_history.dart';

class ChatHistoryService {
  static const String _key = 'saved_conversations_v1';

  static Future<List<SavedConversation>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => SavedConversation.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
  }

  static Future<void> save(SavedConversation conv) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    // إزالة المحادثة إذا كانت موجودة مسبقاً بنفس الـ ID لتحديثها
    final updated = data.where((e) => SavedConversation.fromJson(jsonDecode(e)).id != conv.id).toList();
    updated.add(jsonEncode(conv.toJson()));
    await prefs.setStringList(_key, updated);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    final updated = data.where((e) => SavedConversation.fromJson(jsonDecode(e)).id != id).toList();
    await prefs.setStringList(_key, updated);
  }
}
