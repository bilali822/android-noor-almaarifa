import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WelcomeView extends StatelessWidget {
  final void Function(String) onExample;
  const WelcomeView({super.key, required this.onExample});

  static const _examples = [
    {'label': 'آية الكرسي', 'value': 'آية الكرسي'},
    {'label': 'سورة الإخلاص', 'value': 'الإخلاص'},
    {'label': 'سورة الكهف', 'value': 'الكهف'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), border: Border.all(color: AppColors.primary, width: 1.5), borderRadius: BorderRadius.circular(24)), alignment: Alignment.center, child: const Icon(Icons.menu_book, color: AppColors.primary, size: 40)),
          const SizedBox(height: 24),
          const Text('نور المعرفة', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: 8),
          const Text('اسأل عن أي سورة أو آية من القرآن الكريم لعرض التفاسير المعتمدة', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSoft, fontSize: 14, height: 1.6)),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.start, spacing: 8, runSpacing: 8,
            children: _examples.map((e) => InkWell(onTap: () => onExample(e['value']!), borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: AppColors.bgSurface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)), child: Text(e['label']!, style: const TextStyle(color: AppColors.textSoft, fontSize: 12, fontWeight: FontWeight.w600))))).toList(),
          ),
        ],
      ),
    );
  }
}
