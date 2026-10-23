import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_colors.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasName = prefs.containsKey('user_name');
  runApp(NoorApp(hasName: hasName));
}

// 🌟 إزالة تأثير السكرول الرمادي المزعج في أندرويد (Glow) عشان يبان احترافي
class NoGlowScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class NoorApp extends StatelessWidget {
  final bool hasName;
  const NoorApp({super.key, required this.hasName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نور المعرفة',
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoGlowScrollBehavior(), // 🌟 تفعيل السكرول النظيف
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgDeep,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.bgSurface,
          onPrimary: AppColors.bgDeep,
          onSurface: AppColors.text,
        ),
        fontFamily: 'Cairo',
        // 🌟 تبديل الصفحات بسلاسة (Fade + Slide)
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgDeep,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox(),
      ),
      home: hasName ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}
