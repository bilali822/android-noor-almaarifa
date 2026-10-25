import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

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
        title: const Text('تغيير الاسم'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('حفظ')),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);
      setState(() => _userName = newName);
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
      appBar: AppBar(title: const Text('الإعدادات'), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(leading: const Icon(Icons.person, color: AppColors.primary), title: const Text('تغيير الاسم'), subtitle: Text('الاسم الحالي: $_userName'), onTap: _changeName, trailing: const Icon(Icons.arrow_forward_ios, size: 16)),
          const Divider(),
          ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.danger), title: const Text('حذف الآيات المحفوظة'), onTap: _clearBookmarks),
          const Divider(),
          const ListTile(leading: Icon(Icons.info_outline, color: AppColors.primary), title: Text('عن التطبيق'), subtitle: Text('نور المعرفة - الإصدار 1.0.0\nتطبيق قرآني متكامل يعمل أوفلاين')),
        ],
      ),
    );
  }
}
