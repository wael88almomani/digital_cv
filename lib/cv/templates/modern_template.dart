import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localizations.dart';
import '../models/cv_user.dart';

class ModernTemplate extends StatelessWidget {
  const ModernTemplate({super.key, required this.user, this.imagePath});

  final CvUser user;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final imageFile = imagePath != null ? File(imagePath!) : null;
    final photo = imageFile != null && imageFile.existsSync()
        ? Image.file(imageFile, fit: BoxFit.cover)
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  child: SizedBox(width: 84, height: 84, child: photo),
                ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? l.t('namePlaceholder') : user.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.jobTitle.isEmpty
                          ? l.t('jobPlaceholder')
                          : user.jobTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.royalIndigo,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email.isEmpty ? l.t('emailPlaceholder') : user.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (user.phone.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (user.locations.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ...user.locations.map(
                        (location) => Text(
                          location,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLg),
          _Section(title: l.t('profile'), body: user.about),
          _ListSection(title: l.t('skills'), items: user.skills),
          _ListSection(
            title: l.t('certifications'),
            items: user.certifications,
          ),
          _ListSection(title: l.t('courses'), items: user.courses),
          _ListSection(title: l.t('references'), items: user.references),
          _ListSection(title: l.t('experience'), items: user.experience),
          _ListSection(title: l.t('education'), items: user.education),
          _ListSection(title: l.t('languages'), items: user.languages),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  const _ListSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((item) => Chip(label: Text(item)))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
