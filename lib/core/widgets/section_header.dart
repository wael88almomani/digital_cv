import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (trailing != null) ...[
          const SizedBox(width: AppSizes.spacingSm),
          trailing!,
        ],
      ],
    );
  }
}
