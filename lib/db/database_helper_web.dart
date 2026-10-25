class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<void> init() async {}

  // 1. قائمة السور (114 سورة)
  Future<List<Map<String, Object?>>> getSurahs() async {
    return [
      {'id':1,'name_ar':'الفاتحة','verses_count':7}, {'id':2,'name_ar':'البقرة','verses_count':286},
      {'id':3,'name_ar':'آل عمران','verses_count':200}, {'id':4,'name_ar':'النساء','verses_count':176},
      {'id':5,'name_ar':'المائدة','verses_count':120}, {'id':6,'name_ar':'الأنعام','verses_count':165},
      {'id':7,'name_ar':'الأعراف','verses_count':206}, {'id':8,'name_ar':'الأنفال','verses_count':75},
      {'id':9,'name_ar':'التوبة','verses_count':129}, {'id':10,'name_ar':'يونس','verses_count':109},
      {'id':11,'name_ar':'هود','verses_count':123}, {'id':12,'name_ar':'يوسف','verses_count':111},
      {'id':13,'name_ar':'الرعد','verses_count':43}, {'id':14,'name_ar':'إبراهيم','verses_count':52},
      {'id':15,'name_ar':'الحجر','verses_count':99}, {'id':16,'name_ar':'النحل','verses_count':128},
      {'id':17,'name_ar':'الإسراء','verses_count':111}, {'id':18,'name_ar':'الكهف','verses_count':110},
      {'id':19,'name_ar':'مريم','verses_count':98}, {'id':20,'name_ar':'طه','verses_count':135},
      {'id':21,'name_ar':'الأنبياء','verses_count':112}, {'id':22,'name_ar':'الحج','verses_count':78},
      {'id':23,'name_ar':'المؤمنون','verses_count':118}, {'id':24,'name_ar':'النور','verses_count':64},
      {'id':25,'name_ar':'الفرقان','verses_count':77}, {'id':26,'name_ar':'الشعراء','verses_count':227},
      {'id':27,'name_ar':'النمل','verses_count':93}, {'id':28,'name_ar':'القصص','verses_count':88},
      {'id':29,'name_ar':'العنكبوت','verses_count':69}, {'id':30,'name_ar':'الروم','verses_count':60},
      {'id':31,'name_ar':'لقمان','verses_count':34}, {'id':32,'name_ar':'السجدة','verses_count':30},
      {'id':33,'name_ar':'الأحزاب','verses_count':73}, {'id':34,'name_ar':'سبأ','verses_count':54},
      {'id':35,'name_ar':'فاطر','verses_count':45}, {'id':36,'name_ar':'يس','verses_count':83},
      {'id':37,'name_ar':'الصافات','verses_count':182}, {'id':38,'name_ar':'ص','verses_count':88},
      {'id':39,'name_ar':'الزمر','verses_count':75}, {'id':40,'name_ar':'غافر','verses_count':85},
      {'id':41,'name_ar':'فصلت','verses_count':54}, {'id':42,'name_ar':'الشورى','verses_count':53},
      {'id':43,'name_ar':'الزخرف','verses_count':89}, {'id':44,'name_ar':'الدخان','verses_count':59},
      {'id':45,'name_ar':'الجاثية','verses_count':37}, {'id':46,'name_ar':'الأحقاف','verses_count':35},
      {'id':47,'name_ar':'محمد','verses_count':38}, {'id':48,'name_ar':'الفتح','verses_count':29},
      {'id':49,'name_ar':'الحجرات','verses_count':18}, {'id':50,'name_ar':'ق','verses_count':45},
      {'id':51,'name_ar':'الذاريات','verses_count':60}, {'id':52,'name_ar':'الطور','verses_count':49},
      {'id':53,'name_ar':'النجم','verses_count':62}, {'id':54,'name_ar':'القمر','verses_count':55},
      {'id':55,'name_ar':'الرحمن','verses_count':78}, {'id':56,'name_ar':'الواقعة','verses_count':96},
      {'id':57,'name_ar':'الحديد','verses_count':29}, {'id':58,'name_ar':'المجادلة','verses_count':22},
      {'id':59,'name_ar':'الحشر','verses_count':24}, {'id':60,'name_ar':'الممتحنة','verses_count':13},
      {'id':61,'name_ar':'الصف','verses_count':14}, {'id':62,'name_ar':'الجمعة','verses_count':11},
      {'id':63,'name_ar':'المنافقون','verses_count':11}, {'id':64,'name_ar':'التغابن','verses_count':18},
      {'id':65,'name_ar':'الطلاق','verses_count':12}, {'id':66,'name_ar':'التحريم','verses_count':12},
      {'id':67,'name_ar':'الملك','verses_count':30}, {'id':68,'name_ar':'القلم','verses_count':52},
      {'id':69,'name_ar':'الحاقة','verses_count':52}, {'id':70,'name_ar':'المعارج','verses_count':44},
      {'id':71,'name_ar':'نوح','verses_count':28}, {'id':72,'name_ar':'الجن','verses_count':28},
      {'id':73,'name_ar':'المزمل','verses_count':20}, {'id':74,'name_ar':'المدثر','verses_count':56},
      {'id':75,'name_ar':'القيامة','verses_count':40}, {'id':76,'name_ar':'الإنسان','verses_count':31},
      {'id':77,'name_ar':'المرسلات','verses_count':50}, {'id':78,'name_ar':'النبأ','verses_count':40},
      {'id':79,'name_ar':'النازعات','verses_count':46}, {'id':80,'name_ar':'عبس','verses_count':42},
      {'id':81,'name_ar':'التكوير','verses_count':29}, {'id':82,'name_ar':'الانفطار','verses_count':19},
      {'id':83,'name_ar':'المطففين','verses_count':36}, {'id':84,'name_ar':'الانشقاق','verses_count':25},
      {'id':85,'name_ar':'البروج','verses_count':22}, {'id':86,'name_ar':'الطارق','verses_count':17},
      {'id':87,'name_ar':'الأعلى','verses_count':19}, {'id':88,'name_ar':'الغاشية','verses_count':26},
      {'id':89,'name_ar':'الفجر','verses_count':30}, {'id':90,'name_ar':'البلد','verses_count':20},
      {'id':91,'name_ar':'الشمس','verses_count':15}, {'id':92,'name_ar':'الليل','verses_count':21},
      {'id':93,'name_ar':'الضحى','verses_count':11}, {'id':94,'name_ar':'الشرح','verses_count':8},
      {'id':95,'name_ar':'التين','verses_count':8}, {'id':96,'name_ar':'العلق','verses_count':19},
      {'id':97,'name_ar':'القدر','verses_count':5}, {'id':98,'name_ar':'البينة','verses_count':8},
      {'id':99,'name_ar':'الزلزلة','verses_count':8}, {'id':100,'name_ar':'العاديات','verses_count':11},
      {'id':101,'name_ar':'القارعة','verses_count':11}, {'id':102,'name_ar':'التكاثر','verses_count':8},
      {'id':103,'name_ar':'العصر','verses_count':3}, {'id':104,'name_ar':'الهمزة','verses_count':9},
      {'id':105,'name_ar':'الفيل','verses_count':5}, {'id':106,'name_ar':'قريش','verses_count':4},
      {'id':107,'name_ar':'الماعون','verses_count':7}, {'id':108,'name_ar':'الكوثر','verses_count':3},
      {'id':109,'name_ar':'الكافرون','verses_count':6}, {'id':110,'name_ar':'النصر','verses_count':3},
      {'id':111,'name_ar':'المسد','verses_count':5}, {'id':112,'name_ar':'الإخلاص','verses_count':4},
      {'id':113,'name_ar':'الفلق','verses_count':5}, {'id':114,'name_ar':'الناس','verses_count':6},
    ];
  }

  // إصلاح مشكلة "جاري التحميل" في المصحف
  Future<List<Map<String, Object?>>> getSurah(int id) async {
    final all = await getSurahs();
    final s = all.where((e) => e['id'] == id).toList();
    return s;
  }

  // 2. آيات تجريبية للسور الأكثر استخداماً
  Future<List<Map<String, Object?>>> getVerses(int surahId) async {
    if (surahId == 1) {
      return [
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 1, 'text_ar': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 2, 'text_ar': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 3, 'text_ar': 'الرَّحْمَٰنِ الرَّحِيمِ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 4, 'text_ar': 'مَالِكِ يَوْمِ الدِّينِ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 5, 'text_ar': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 6, 'text_ar': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ'},
        {'surah_id': 1, 'surah_name': 'الفاتحة', 'verse_number': 7, 'text_ar': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ'},
      ];
    }
    if (surahId == 112) {
      return [
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 1, 'text_ar': 'قُلْ هُوَ اللَّهُ أَحَدٌ'},
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 2, 'text_ar': 'اللَّهُ الصَّمَدُ'},
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 3, 'text_ar': 'لَمْ يَلِدْ وَلَمْ يُولَدْ'},
        {'surah_id': 112, 'surah_name': 'الإخلاص', 'verse_number': 4, 'text_ar': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ'},
      ];
    }
    return []; // باقي السور تظهر رسالة "غير متاحة في الويب"
  }

  Future<List<Map<String, Object?>>> getVerse(int surahId, int verseNumber) async {
    final verses = await getVerses(surahId);
    return verses.where((v) => v['verse_number'] == verseNumber).toList();
  }

  // 3. التفاسير التجريبية
  Future<List<Map<String, Object?>>> getTafsirs(int surahId, int verseNumber) async {
    return [
      {'book_key': 'muyassar', 'text_ar': 'التفسير الميسر: هذا نص تجريبي للمعاينة على الويب. قم بتثبيت التطبيق للحصول على التفسير الكامل.'}
    ];
  }

  Future<List<Map<String, Object?>>> getTafsirBooks() async {
    return [{'key': 'muyassar', 'name_ar': 'التفسير الميسر'}];
  }

  Future<List<Map<String, Object?>>> getTafsirBooksForVerse(int surahId, int verseNumber) async {
    final all = await getTafsirs(surahId, verseNumber);
    if (all.isEmpty) return [];
    final allBooks = await getTafsirBooks();
    final available = all.map((t) => t['book_key']).toSet();
    return allBooks.where((b) => available.contains(b['key'])).toList();
  }

  Future<List<Map<String, Object?>>> searchVerses(String query, {int limit = 100}) async => [];

  // 4. بيانات الأحاديث التجريبية (لكي يعمل التصميم الجديد)
  Future<List<Map<String, Object?>>> getHadiths() async {
    return [
      {'id': 1, 'book': 'صحيح البخاري', 'hadith_number': 1, 'arabic_text': 'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى، فمن كانت هجرته إلى الله ورسوله فهجرته إلى الله ورسوله، ومن كانت هجرته لدنيا يصيبها أو امرأة ينكحها فهجرته إلى ما هاجر إليه.', 'narrator': 'عمر بن الخطاب', 'grade': 'صحيح'},
      {'id': 2, 'book': 'صحيح البخاري', 'hadith_number': 8, 'arabic_text': 'بني الإسلام على خمس: شهادة أن لا إله إلا الله وأن محمداً رسول الله، وإقام الصلاة، وإيتاء الزكاة، وحج البيت، وصوم رمضان.', 'narrator': 'عبد الله بن عمر', 'grade': 'صحيح'},
      {'id': 3, 'book': 'صحيح مسلم', 'hadith_number': 45, 'arabic_text': 'من كان يؤمن بالله واليوم الآخر فليقل خيراً أو ليصمت.', 'narrator': 'أبو هريرة', 'grade': 'صحيح'},
      {'id': 4, 'book': 'صحيح مسلم', 'hadith_number': 101, 'arabic_text': 'الطهور شطر الإيمان، والحمد لله تملأ الميزان.', 'narrator': 'أبو مالك الأشعري', 'grade': 'صحيح'},
      {'id': 5, 'book': 'سنن الترمذي', 'hadith_number': 2001, 'arabic_text': 'اتق الله حيثما كنت، وأتبع السيئة الحسنة تمحها، وخالق الناس بخلق حسن.', 'narrator': 'أبو ذر الغفاري', 'grade': 'حسن'},
    ];
  }

  Future<List<Map<String, Object?>>> getHadithsPaginated(int limit, int offset) async {
    final all = await getHadiths();
    if (offset >= all.length) return [];
    return all.skip(offset).take(limit).toList();
  }

  Future<List<Map<String, Object?>>> getHadithBooks() async {
    return [
      {'name': 'صحيح البخاري'},
      {'name': 'صحيح مسلم'},
      {'name': 'سنن الترمذي'}
    ];
  }

  Future<List<Map<String, Object?>>> getHadithsByBook(String book) async {
    final all = await getHadiths();
    return all.where((h) => h['book'] == book).toList();
  }

  Future<List<Map<String, Object?>>> searchHadiths(String query) async {
    final all = await getHadiths();
    return all.where((h) => (h['arabic_text'] as String).contains(query) || (h['narrator'] as String).contains(query)).toList();
  }
}
