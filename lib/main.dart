import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NoorApp());
}

class NoorApp extends StatelessWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نور المعرفة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFFFF6B9D),
          surface: Color(0xFF12122E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF12122E),
          elevation: 0,
        ),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // إجبار RTL
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
