import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/data/auth_service.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_background.dart';
import '../data/cv_repository.dart';
import '../models/cv_document.dart';
import '../models/cv_user.dart';
import 'edit_cv_screen.dart';
import 'preview_cv_screen.dart';

/// Screen for managing multiple CVs - create, activate, delete
class CvListScreen extends StatelessWidget {
  const CvListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('myCvs'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.spacingSm),
                Text(
                  l.t('myCvsHint'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                Expanded(
                  child: StreamBuilder<List<CvDocument>>(
                    stream: context.read<CvRepository>().watchUserCvs(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final cvs = snapshot.data ?? [];

                      if (cvs.isEmpty) {
                        return _EmptyState(
                          onCreateCv: () => _createNewCv(context, user.uid),
                        );
                      }

                      return ListView.separated(
                        itemCount: cvs.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSizes.spacingSm),
                        itemBuilder: (context, index) {
                          final cv = cvs[index];
                          return _CvCard(
                            cv: cv,
                            cvCount: cvs.length,
                            onActivate: () => _setActiveCv(context, cv),
                            onEdit: () => _editCv(context, cv),
                            onDelete: () => _deleteCv(context, cv, cvs.length),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewCv(context, user.uid),
        icon: const Icon(Icons.add),
        label: Text(l.t('createNewCv')),
      ),
    );
  }

  Future<void> _createNewCv(BuildContext context, String userId) async {
    final l = AppLocalizations.of(context);
    final repo = context.read<CvRepository>();
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    // Show dialog to enter CV title and select language
    final result = await showDialog<(String, CvLanguage)>(
      context: context,
      builder: (context) => _CreateCvDialog(
        defaultTitle:
            '${l.t('myCv')} ${DateTime.now().millisecondsSinceEpoch % 1000}',
      ),
    );

    if (result == null || result.$1.trim().isEmpty || !context.mounted) return;

    final (title, cvLanguage) = result;

    // Get current CV count to determine if first
    final count = await repo.getCvCount(userId);
    final isFirst = count == 0;

    final newCv = CvDocument.empty(
      userId: userId,
      userName: user?.displayName ?? '',
      userEmail: user?.email ?? '',
      title: title.trim(),
      isActive: isFirst, // First CV is automatically active
      cvLanguage: cvLanguage,
    );

    await repo.createCv(newCv);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('cvCreated'))));
    }
  }

  Future<void> _setActiveCv(BuildContext context, CvDocument cv) async {
    final l = AppLocalizations.of(context);
    final repo = context.read<CvRepository>();
    await repo.setActiveCv(cv.userId, cv.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${cv.title} ${l.t('isNowActive')}')),
      );
    }
  }

  Future<void> _editCv(BuildContext context, CvDocument cv) async {
    final cvUser = cv.toCvUser();
    final updated = await Navigator.of(context).push<CvUser>(
      MaterialPageRoute(
        builder: (_) => EditCvScreen(user: cvUser, cvId: cv.id),
      ),
    );
    if (!context.mounted) return;
    if (updated != null) {
      await context.read<CvRepository>().updateCv(cv.id, updated.toMap());
    }
  }

  Future<void> _deleteCv(
    BuildContext context,
    CvDocument cv,
    int cvCount,
  ) async {
    final l = AppLocalizations.of(context);

    // Can't delete the last CV
    if (cvCount <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('cantDeleteLastCv'))));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('deleteCv')),
        content: Text('${l.t('deleteCvConfirm')}\n\n"${cv.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CvRepository>().deleteCv(cv.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateCv});

  final VoidCallback onCreateCv;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(l.t('noCvsYet'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            l.t('createFirstCv'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSizes.spacingLg),
          ElevatedButton.icon(
            onPressed: onCreateCv,
            icon: const Icon(Icons.add),
            label: Text(l.t('createNewCv')),
          ),
        ],
      ),
    );
  }
}

class _CvCard extends StatelessWidget {
  const _CvCard({
    required this.cv,
    required this.cvCount,
    required this.onActivate,
    required this.onEdit,
    required this.onDelete,
  });

  final CvDocument cv;
  final int cvCount;
  final VoidCallback onActivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: cv.isActive ? null : onActivate,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Active indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cv.isActive
                        ? Colors.green
                        : Colors.grey.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // CV info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cv.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Language badge
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cv.cvLanguage.displayName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (cv.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l.t('active'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (cv.jobTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          cv.jobTitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(cv.updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'activate':
                        onActivate();
                        break;
                      case 'edit':
                        onEdit();
                        break;
                      case 'preview':
                        _previewCv(context);
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!cv.isActive)
                      PopupMenuItem(
                        value: 'activate',
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(l.t('setAsActive')),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(l.t('editCv')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          const Icon(Icons.visibility_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(l.t('previewCv')),
                        ],
                      ),
                    ),
                    if (cvCount > 1) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l.t('delete'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (!cv.isActive) ...[
              const SizedBox(height: AppSizes.spacingSm),
              Text(
                l.t('tapToActivate'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _previewCv(BuildContext context) {
    final cvUser = cv.toCvUser();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewCvScreen(
          user: cvUser,
          cvLanguage: cv.cvLanguage,
          cvId: cv.id,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CreateCvDialog extends StatefulWidget {
  const _CreateCvDialog({required this.defaultTitle});

  final String defaultTitle;

  @override
  State<_CreateCvDialog> createState() => _CreateCvDialogState();
}

class _CreateCvDialogState extends State<_CreateCvDialog> {
  late final TextEditingController _controller;
  CvLanguage _selectedLanguage = CvLanguage.arabic;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l.t('createNewCv')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l.t('cvTitle'),
              hintText: l.t('cvTitleHint'),
            ),
            onSubmitted: (value) => _submit(),
          ),
          const SizedBox(height: 16),
          // Language Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.t('cvLanguage'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<CvLanguage>(
                segments: const [
                  ButtonSegment<CvLanguage>(
                    value: CvLanguage.arabic,
                    label: Text('العربية'),
                  ),
                  ButtonSegment<CvLanguage>(
                    value: CvLanguage.english,
                    label: Text('English'),
                  ),
                ],
                selected: {_selectedLanguage},
                onSelectionChanged: (selected) {
                  setState(() => _selectedLanguage = selected.first);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.t('cancel')),
        ),
        ElevatedButton(onPressed: _submit, child: Text(l.t('create'))),
      ],
    );
  }

  void _submit() {
    Navigator.of(context).pop((_controller.text, _selectedLanguage));
  }
}
