import 'dart:convert';

class SavedMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? verseData;
  final List<Map<String, dynamic>>? tafsirData;
  final String time;

  SavedMessage({
    required this.text, 
    required this.isUser, 
    this.verseData, 
    this.tafsirData, 
    required this.time
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'verseData': verseData,
    'tafsirData': tafsirData,
    'time': time,
  };

  factory SavedMessage.fromJson(Map<String, dynamic> json) => SavedMessage(
    text: json['text'],
    isUser: json['isUser'],
    verseData: json['verseData'] != null ? Map<String, dynamic>.from(json['verseData']) : null,
    tafsirData: json['tafsirData'] != null 
        ? List<Map<String, dynamic>>.from(json['tafsirData'].map((x) => Map<String, dynamic>.from(x))) 
        : null,
    time: json['time'],
  );
}

class SavedConversation {
  final String id;
  final String title;
  final String type;
  final String date;
  final List<SavedMessage> messages;

  SavedConversation({
    required this.id, 
    required this.title, 
    required this.type, 
    required this.date, 
    required this.messages
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'date': date,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory SavedConversation.fromJson(Map<String, dynamic> json) => SavedConversation(
    id: json['id'],
    title: json['title'],
    type: json['type'],
    date: json['date'],
    messages: (json['messages'] as List).map((m) => SavedMessage.fromJson(m)).toList(),
  );
}
