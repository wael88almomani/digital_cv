import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/app_card.dart';

class TemplatePickerSheet extends StatelessWidget {
  const TemplatePickerSheet({super.key, required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('chooseTemplate'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.spacing),
                _TemplateTile(
                  label: l.t('modernTemplate'),
                  value: AppStrings.templateModern,
                  selected: selected,
                ),
                const SizedBox(height: AppSizes.spacingSm),
                _TemplateTile(
                  label: l.t('classicTemplate'),
                  value: AppStrings.templateClassic,
                  selected: selected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.label,
    required this.value,
    required this.selected,
  });

  final String label;
  final String value;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(value),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(
            color: value == selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value == AppStrings.templateModern
                  ? Icons.auto_awesome_outlined
                  : Icons.article_outlined,
            ),
            const SizedBox(width: AppSizes.spacingSm),
            Expanded(child: Text(label)),
            if (value == selected) const Icon(Icons.check_circle_outline),
          ],
        ),
      ),
    );
  }
}
