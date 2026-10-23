// استدعاء قاعدة البيانات حسب نوع المنصة (موبايل أم ويب)
export 'database_helper_io.dart' if (dart.library.js_interop) 'database_helper_web.dart';
