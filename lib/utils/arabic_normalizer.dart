class ArabicNormalizer {
  /// دالة لتطبيع النص العربي وإزالة الحركات
  static String normalize(String text) {
    if (text.isEmpty) return text;

    // 1. إزالة التشكيل (الفتحة، الضمة، الكسرة، السكون، الشدة، التنوين)
    // النطاق \u064B إلى \u065F يشمل معظم الحركات
    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    // 2. إزالة الرموز القرآنية (مثل: علامات الوقف الصغيرة)
    text = text.replaceAll(RegExp(r'[\u06D6-\u06ED]'), '');

    // 3. إزالة التطويل (الكشيدة)
    text = text.replaceAll('\u0640', '');

    // 4. توحيد الألف (أ، إ، آ -> ا)
    text = text.replaceAll(RegExp(r'[أإآ]'), 'ا');

    // 5. توحيد الياء (ى -> ي)
    text = text.replaceAll('ى', 'ي');

    // 6. توحيد التاء المربوطة (ة -> ه) - لزيادة مرونة البحث
    text = text.replaceAll('ة', 'ه');

    // 7. إزالة المسافات الزائدة
    text = text.trim().replaceAll(RegExp(r'\s+'), ' ');

    return text;
  }
}
