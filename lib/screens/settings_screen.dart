import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/quranic_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('user_name') ?? 'زائر');
  }

  Future<void> _changeName() async {
    final controller = TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('تغيير الاسم', style: TextStyle(color: AppColors.text)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.bgDeep,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppColors.textMuted))),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('حفظ', style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);
      setState(() => _userName = newName);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير الاسم بنجاح')));
    }
  }

  Future<void> _clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookmarks');
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف كل الآيات المحفوظة')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Stack(
        children: [
          const QuranicBackground(child: SizedBox.expand()),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primary),
                  title: const Text('تغيير الاسم', style: TextStyle(color: AppColors.text)),
                  subtitle: Text('الاسم الحالي: $_userName', style: const TextStyle(color: AppColors.textMuted)),
                  onTap: _changeName,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
                ),
                const Divider(color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                  title: const Text('حذف الآيات المحفوظة', style: TextStyle(color: AppColors.text)),
                  onTap: _clearBookmarks,
                ),
                const Divider(color: AppColors.border),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text('عن التطبيق', style: TextStyle(color: AppColors.text)),
                  subtitle: Text('نور المعرفة - الإصدار 1.0.0\nتطبيق قرآني متكامل يعمل أوفلاين', style: TextStyle(color: AppColors.textMuted, height: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
