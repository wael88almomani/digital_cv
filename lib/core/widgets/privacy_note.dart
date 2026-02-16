import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class PrivacyNote extends StatelessWidget {
  const PrivacyNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingSm),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1B2D) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2A44) : const Color(0xFFDBEAFE),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.privacy_tip_outlined, color: AppColors.emerald),
          const SizedBox(width: AppSizes.spacingSm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
