import 'package:flutter/material.dart';

import '../core/constants/app_sizes.dart';
import '../core/localization/app_localizations.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).t('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingLg),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: AppLocalizations.of(context).t('theme')),
                  const SizedBox(height: AppSizes.spacingSm),
                  Text(
                    AppLocalizations.of(context).t('darkModeNote'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
