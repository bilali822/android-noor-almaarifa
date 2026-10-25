import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تفعيل الشاشة الكاملة
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  final prefs = await SharedPreferences.getInstance();
  final bool seenWelcome = prefs.getBool('seen_welcome') ?? false;

  runApp(NoorApp(seenWelcome: seenWelcome));
}

class NoorApp extends StatelessWidget {
  final bool seenWelcome;
  const NoorApp({super.key, required this.seenWelcome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نور المعرفة',
      debugShowCheckedModeBanner: false,
      // 🌟 إجبار التطبيق على الاتجاه من اليمين لليسار واللغة العربية
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar')],
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bgDeep,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      home: seenWelcome ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}
