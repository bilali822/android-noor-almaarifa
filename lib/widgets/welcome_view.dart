import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WelcomeView extends StatelessWidget {
  final void Function(String) onExample;

  const WelcomeView({super.key, required this.onExample});

  static const _examples = [
    {'label': 'سورة البقرة', 'value': 'البقرة'},
    {'label': 'آية الكرسي', 'value': 'آية الكرسي'},
    {'label': 'سورة الإخلاص', 'value': 'الإخلاص'},
    {'label': 'سورة يس', 'value': 'يس'},
    {'label': 'البقرة ١-٥', 'value': 'البقرة ١-٥'},
    {'label': '2:255', 'value': '2:255'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.menu_book, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 24),

          const Text(
            'نور المعرفة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'اسأل عن أي سورة أو آية من القرآن الكريم لعرض التفاسير المعتمدة',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 32),

          Row(
            children: const [
              Expanded(child: _FeatureCard(icon: Icons.library_books, title: '114 سورة')),
              SizedBox(width: 12),
              Expanded(child: _FeatureCard(icon: Icons.auto_stories, title: '6 تفاسير')),
              SizedBox(width: 12),
              Expanded(child: _FeatureCard(icon: Icons.bolt, title: 'أوفلاين')),
            ],
          ),
          const SizedBox(height: 32),

          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'أمثلة سريعة',
              style: TextStyle(color: AppColors.textSoft, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: _examples
                .map((e) => _QuickButton(
                      label: e['label']!,
                      onTap: () => onExample(e['value']!),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _FeatureCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSoft, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
