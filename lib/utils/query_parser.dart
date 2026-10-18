class QueryParser {
  static const Map<String, int> surahMap = {
    "الفاتحة":1,"البقرة":2,"آل عمران":3,"النساء":4,"المائدة":5,"الأنعام":6,
    "الأعراف":7,"الأنفال":8,"التوبة":9,"يونس":10,"هود":11,"يوسف":12,
    "الرعد":13,"إبراهيم":14,"الحجر":15,"النحل":16,"الإسراء":17,"الكهف":18,
    "مريم":19,"طه":20,"الأنبياء":21,"الحج":22,"المؤمنون":23,"النور":24,
    "الفرقان":25,"الشعراء":26,"النمل":27,"القصص":28,"العنكبوت":29,"الروم":30,
    "لقمان":31,"السجدة":32,"الأحزاب":33,"سبأ":34,"فاطر":35,"يس":36,
    "الصافات":37,"ص":38,"الزمر":39,"غافر":40,"فصلت":41,"الشورى":42,
    "الزخرف":43,"الدخان":44,"الجاثية":45,"الأحقاف":46,"محمد":47,"الفتح":48,
    "الحجرات":49,"ق":50,"الذاريات":51,"الطور":52,"النجم":53,"القمر":54,
    "الرحمن":55,"الواقعة":56,"الحديد":57,"المجادلة":58,"الحشر":59,
    "الممتحنة":60,"الصف":61,"الجمعة":62,"المنافقون":63,"التغابن":64,
    "الطلاق":65,"التحريم":66,"الملك":67,"القلم":68,"الحاقة":69,"المعارج":70,
    "نوح":71,"الجن":72,"المزمل":73,"المدثر":74,"القيامة":75,"الإنسان":76,
    "المرسلات":77,"النبأ":78,"النازعات":79,"عبس":80,"التكوير":81,
    "الانفطار":82,"المطففين":83,"الانشقاق":84,"البروج":85,"الطارق":86,
    "الأعلى":87,"الغاشية":88,"الفجر":89,"البلد":90,"الشمس":91,"الليل":92,
    "الضحى":93,"الشرح":94,"التين":95,"العلق":96,"القدر":97,"البينة":98,
    "الزلزلة":99,"العاديات":100,"القارعة":101,"التكاثر":102,"العصر":103,
    "الهمزة":104,"الفيل":105,"قريش":106,"الماعون":107,"الكوثر":108,
    "الكافرون":109,"النصر":110,"المسد":111,"الإخلاص":112,"الفلق":113,"الناس":114,
  };

  static const List<Map<String, dynamic>> specialVerses = [
    {"name": "آية الكرسي", "s": 2, "v": 255, "e": 255},
    {"name": "اية الكرسي", "s": 2, "v": 255, "e": 255},
    {"name": "آية النور", "s": 24, "v": 35, "e": 35},
    {"name": "آية المواريث", "s": 4, "v": 11, "e": 11},
    {"name": "آية الدين", "s": 2, "v": 282, "e": 282},
    {"name": "آية الوضوء", "s": 5, "v": 6, "e": 6},
    {"name": "خواتيم البقرة", "s": 2, "v": 285, "e": 286},
  ];

  static String convertNumbers(String text) {
    const ar = '٠١٢٣٤٥٦٧٨٩';
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    String result = text;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(ar[i], '$i');
      result = result.replaceAll(fa[i], '$i');
    }
    return result;
  }

  static String normalize(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static int? findSurah(String text) {
    if (text.isEmpty) return null;
    final n = normalize(text);

    for (final e in surahMap.entries) {
      if (normalize(e.key) == n) return e.value;
    }
    for (final e in surahMap.entries) {
      if (n.contains(normalize(e.key))) return e.value;
    }
    for (final w in n.split(' ')) {
      if (w.length < 3) continue;
      for (final e in surahMap.entries) {
        final nn = normalize(e.key);
        if (nn.contains(w) || w.contains(nn)) return e.value;
      }
    }
    return null;
  }

  static Map<String, dynamic> parse(String query) {
    final original = convertNumbers(query.trim());
    final n = normalize(original);

    for (final sp in specialVerses) {
      if (n.contains(normalize(sp['name'] as String))) {
        final v = sp['v'] as int;
        final e = sp['e'] as int;
        return {
          'type': v == e ? 'verse' : 'range',
          'surahId': sp['s'] as int,
          'verseNumber': v,
          'startVerse': v,
          'endVerse': e,
          'original': original,
        };
      }
    }

    final m1 = RegExp(r'(\d+)\s*[:：]\s*(\d+)').firstMatch(original);
    if (m1 != null) {
      final sid = int.parse(m1.group(1)!);
      final vn = int.parse(m1.group(2)!);
      if (sid >= 1 && sid <= 114) {
        return {'type': 'verse', 'surahId': sid, 'verseNumber': vn, 'original': original};
      }
    }

    final m2 = RegExp(r'(\d+)\s*(?:إلى|الى|حتى|-|–)\s*(\d+)').firstMatch(original);
    if (m2 != null) {
      final v1 = int.parse(m2.group(1)!);
      final v2 = int.parse(m2.group(2)!);
      final sid = findSurah(original);
      if (sid != null && v1 <= v2 && (v2 - v1) < 200) {
        return {
          'type': 'range', 'surahId': sid,
          'startVerse': v1, 'endVerse': v2, 'original': original,
        };
      }
    }

    final nums = RegExp(r'\d+').allMatches(original).toList();
    final sid2 = findSurah(original);
    if (sid2 != null && nums.isNotEmpty) {
      final vn = int.parse(nums.last.group(0)!);
      if (vn >= 1 && vn <= 300) {
        return {'type': 'verse', 'surahId': sid2, 'verseNumber': vn, 'original': original};
      }
    }

    if (sid2 != null) {
      return {'type': 'surah', 'surahId': sid2, 'original': original};
    }

    if (RegExp(r'^\d+$').hasMatch(original)) {
      final v = int.parse(original);
      if (v >= 1 && v <= 114) {
        return {'type': 'surah', 'surahId': v, 'original': original};
      }
    }

    return {'type': 'search', 'term': n.length >= 2 ? n : null, 'original': original};
  }
}
