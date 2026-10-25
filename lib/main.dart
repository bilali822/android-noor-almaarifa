import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تفعيل الشاشة الكاملة
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
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
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bgDeep,
        fontFamily: 'Cairo',
      ),
      home: seenWelcome ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}
