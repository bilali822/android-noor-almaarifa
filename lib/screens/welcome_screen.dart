import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.menu_book, color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 32),
              const Text(
                'مرحباً بك في نور المعرفة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 12),
              const Text(
                'يرجى إدخال اسمك للبدء',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.text, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'الاسم هنا...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.bgDeep,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.bgDeep, strokeWidth: 2))
                      : const Text('متابعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
