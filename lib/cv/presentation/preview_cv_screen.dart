import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/section_header.dart';
import '../data/local_image_store.dart';
import '../models/cv_document.dart';
import '../models/cv_user.dart';
import '../pdf/arabic_cv_pdf_builder.dart';
import '../pdf/cv_pdf_builder.dart';
import '../templates/classic_template.dart';
import '../templates/modern_template.dart';

class PreviewCvScreen extends StatelessWidget {
  const PreviewCvScreen({
    super.key,
    required this.user,
    this.cvLanguage = CvLanguage.arabic,
    this.cvId,
  });

  final CvUser user;
  final CvLanguage cvLanguage;
  final String? cvId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final imageStore = context.read<LocalImageStore>();
    final imagePath = cvId != null
        ? imageStore.getImagePathForCv(cvId!)
        : imageStore.getImagePath();
    final isModern = user.selectedTemplate == AppStrings.templateModern;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('previewCv'))),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: isModern ? l.t('modernTemplate') : l.t('classicTemplate'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cvLanguage.displayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isModern
                        ? Icons.auto_awesome_outlined
                        : Icons.article_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing),
            Expanded(
              child: SingleChildScrollView(
                child: isModern
                    ? ModernTemplate(user: user, imagePath: imagePath)
                    : ClassicTemplate(user: user, imagePath: imagePath),
              ),
            ),
            const SizedBox(height: AppSizes.spacing),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: l.t('sharePdf'),
                    onPressed: () => _sharePdf(context, imagePath, l),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSm),
                Expanded(
                  child: PrimaryButton(
                    label: l.t('exportPdf'),
                    onPressed: () => _exportPdf(context, imagePath, l),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePdf(
    BuildContext context,
    String? imagePath,
    AppLocalizations l,
  ) async {
    try {
      final bytes = await _buildPdfBytes(imagePath, l);
      await Printing.sharePdf(bytes: bytes, filename: 'digital_cv.pdf');
    } catch (error) {
      debugPrint('Share PDF failed: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('shareFail'))));
    }
  }

  Future<void> _exportPdf(
    BuildContext context,
    String? imagePath,
    AppLocalizations l,
  ) async {
    try {
      final bytes = await _buildPdfBytes(imagePath, l);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (error) {
      debugPrint('Export PDF failed: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('exportFail'))));
    }
  }

  Future<Uint8List> _buildPdfBytes(
    String? imagePath,
    AppLocalizations l,
  ) async {
    if (cvLanguage == CvLanguage.arabic) {
      // Use Arabic PDF builder
      return ArabicCvPdfBuilder().buildArabicPdf(
        user,
        imagePath: imagePath,
        labels: ArabicCvLabels.arabic(),
      );
    } else {
      // Use English PDF builder
      return CvPdfBuilder().buildPdf(
        user,
        imagePath: imagePath,
        labels: CvPdfLabels.fromLocalizations(l),
      );
    }
  }
}
