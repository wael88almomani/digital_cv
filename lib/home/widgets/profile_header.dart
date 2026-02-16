import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localizations.dart';
import '../../cv/models/cv_user.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user, this.imagePath});

  final CvUser user;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final imageFile = imagePath != null ? File(imagePath!) : null;
    final photo = imageFile != null && imageFile.existsSync()
        ? FileImage(imageFile)
        : null;

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: photo,
          child: photo == null ? const Icon(Icons.person_outline) : null,
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name.isEmpty ? l.t('namePlaceholder') : user.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                user.jobTitle.isEmpty ? l.t('jobPlaceholder') : user.jobTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
