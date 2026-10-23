package com.noor.almaarifa.noor_app

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 🌟 إجبار التطبيق على الرسم خلف أشرطة النظام
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // 🌟 تعطيل التباين في شريط التنقل (لمنع المساحة السوداء)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
    }
}
