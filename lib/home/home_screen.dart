import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/data/auth_service.dart';
import '../core/constants/app_sizes.dart';
import '../core/localization/app_localizations.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/gradient_background.dart';
import '../core/widgets/progress_bar.dart';
import '../core/widgets/section_header.dart';
import '../cv/data/cv_repository.dart';
import '../cv/data/local_image_store.dart';
import '../cv/models/cv_document.dart';
import '../cv/models/cv_user.dart';
import '../cv/presentation/edit_cv_screen.dart';
import '../cv/presentation/preview_cv_screen.dart';
import '../cv/presentation/template_picker_sheet.dart';
import '../home/widgets/action_tile.dart';
import '../home/widgets/profile_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<CvDocument?>(
      stream: context.read<CvRepository>().watchActiveCv(user.uid),
      builder: (context, snapshot) {
        // No active CV - show prompt to create one
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.data == null) {
          return _NoCvState(userId: user.uid);
        }

        if (snapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final activeCv = snapshot.data!;
        final cvUser = activeCv.toCvUser();
        final cvLanguage = activeCv.cvLanguage;
        final completion = _completionScore(cvUser);
        final imagePath = context.read<LocalImageStore>().getImagePathForCv(
          activeCv.id,
        );

        return Scaffold(
          body: GradientBackground(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.spacingSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.t('dashboard'),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Row(
                              children: [
                                Text(
                                  activeCv.title,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    cvLanguage.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeader(user: cvUser, imagePath: imagePath),
                        const SizedBox(height: AppSizes.spacingSm),
                        Text(l.t('cvCompletion')),
                        const SizedBox(height: 8),
                        ProgressBar(value: completion),
                        const SizedBox(height: 8),
                        Text('${(completion * 100).round()}%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingLg),
                  SectionHeader(title: l.t('actions')),
                  const SizedBox(height: AppSizes.spacingSm),
                  Expanded(
                    child: ListView(
                      children: [
                        ActionTile(
                          title: l.t('editCv'),
                          subtitle: l.t('editCvSubtitle'),
                          icon: Icons.edit_outlined,
                          onTap: () async {
                            final updated = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditCvScreen(
                                  user: cvUser,
                                  cvId: activeCv.id,
                                ),
                              ),
                            );
                            if (!context.mounted) return;
                            if (updated is CvUser) {
                              // Update the active CV document
                              await context.read<CvRepository>().updateCv(
                                activeCv.id,
                                updated.toMap(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: AppSizes.spacingSm),
                        ActionTile(
                          title: l.t('previewCv'),
                          subtitle: l.t('previewCvSubtitle'),
                          icon: Icons.visibility_outlined,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PreviewCvScreen(
                                  user: cvUser,
                                  cvLanguage: cvLanguage,
                                  cvId: activeCv.id,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSizes.spacingSm),
                        ActionTile(
                          title: l.t('changeTemplate'),
                          subtitle: l.t('changeTemplateSubtitle'),
                          icon: Icons.auto_awesome_outlined,
                          onTap: () async {
                            final selected = await showModalBottomSheet<String>(
                              context: context,
                              builder: (_) => TemplatePickerSheet(
                                selected: cvUser.selectedTemplate,
                              ),
                            );
                            if (!context.mounted) return;
                            if (selected != null &&
                                selected != cvUser.selectedTemplate) {
                              await context.read<CvRepository>().updateCv(
                                activeCv.id,
                                {'selectedTemplate': selected},
                              );
                            }
                          },
                        ),
                        const SizedBox(height: AppSizes.spacingSm),
                        ActionTile(
                          title: l.t('exportPdf'),
                          subtitle: l.t('exportPdfSubtitle'),
                          icon: Icons.picture_as_pdf_outlined,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PreviewCvScreen(
                                  user: cvUser,
                                  cvLanguage: cvLanguage,
                                  cvId: activeCv.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _completionScore(CvUser user) {
    final fields = [user.name, user.email, user.jobTitle, user.about];
    final listFields = [
      user.skills,
      user.experience,
      user.education,
      user.languages,
    ];
    final filledCount = fields.where((value) => value.trim().isNotEmpty).length;
    final listCount = listFields.where((list) => list.isNotEmpty).length;
    final total = fields.length + listFields.length;
    return (filledCount + listCount) / total;
  }
}

/// Shown when user has no active CV
class _NoCvState extends StatelessWidget {
  const _NoCvState({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSizes.spacing),
                Text(
                  l.t('noCvsYet'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSizes.spacingSm),
                Text(
                  l.t('createFirstCvHint'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingLg),
                Text(
                  l.t('goToMyCvs'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
