import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/localization/app_localizations.dart';
import '../models/cv_user.dart';

class CvPdfBuilder {
  // Colors matching the design
  static const _sidebarColor = PdfColor.fromInt(0xFF1E3A5F); // Dark blue
  static const _accentColor = PdfColor.fromInt(0xFF2196F3); // Light blue
  static const _whiteColor = PdfColors.white;
  static const _textDark = PdfColor.fromInt(0xFF333333);
  static const _textGrey = PdfColor.fromInt(0xFF666666);

  Future<Uint8List> buildPdf(
    CvUser user, {
    String? imagePath,
    required CvPdfLabels labels,
  }) async {
    final doc = pw.Document();
    final isRtl = labels.isRtl;
    final arabicRegular = await _loadArabicFontRegularSafe();
    final arabicBold = await _loadArabicFontExtraBoldSafe();
    final fontRegular = isRtl ? arabicRegular : pw.Font.helvetica();
    final fontBold = isRtl ? arabicBold : pw.Font.helveticaBold();
    final fallbackFonts = <pw.Font>[arabicRegular];

    final imageProvider = await _loadImage(imagePath);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Directionality(
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: isRtl
                  ? [
                      // RTL: Right side (blue sidebar)
                      _buildSidebar(
                        user: user,
                        imageProvider: imageProvider,
                        fontBold: fontBold,
                        fontRegular: fontRegular,
                        fallbackFonts: fallbackFonts,
                        labels: labels,
                        isRtl: isRtl,
                      ),
                      // RTL: Left side (white content)
                      _buildMainContent(
                        user: user,
                        fontBold: fontBold,
                        fontRegular: fontRegular,
                        fallbackFonts: fallbackFonts,
                        labels: labels,
                        isRtl: isRtl,
                      ),
                    ]
                  : [
                      // LTR: Left side (blue sidebar)
                      _buildSidebar(
                        user: user,
                        imageProvider: imageProvider,
                        fontBold: fontBold,
                        fontRegular: fontRegular,
                        fallbackFonts: fallbackFonts,
                        labels: labels,
                        isRtl: isRtl,
                      ),
                      // LTR: Right side (white content)
                      _buildMainContent(
                        user: user,
                        fontBold: fontBold,
                        fontRegular: fontRegular,
                        fallbackFonts: fallbackFonts,
                        labels: labels,
                        isRtl: isRtl,
                      ),
                    ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  /// Blue sidebar with photo, name, contact, languages
  pw.Widget _buildSidebar({
    required CvUser user,
    required pw.ImageProvider? imageProvider,
    required pw.Font fontBold,
    required pw.Font fontRegular,
    required List<pw.Font> fallbackFonts,
    required CvPdfLabels labels,
    required bool isRtl,
  }) {
    final nameValue = user.name.isEmpty ? labels.namePlaceholder : user.name;

    return pw.Container(
      width: 200,
      color: _sidebarColor,
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: isRtl
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          // Profile Photo
          pw.Center(
            child: pw.Container(
              width: 120,
              height: 120,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: _whiteColor, width: 4),
                image: imageProvider != null
                    ? pw.DecorationImage(
                        image: imageProvider,
                        fit: pw.BoxFit.cover,
                      )
                    : null,
                color: imageProvider == null ? _accentColor : null,
              ),
              child: imageProvider == null
                  ? pw.Center(
                      child: pw.Text(
                        nameValue.isNotEmpty ? nameValue[0].toUpperCase() : '?',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 48,
                          color: _whiteColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          pw.SizedBox(height: 20),

          // Name
          pw.Center(
            child: pw.Text(
              nameValue.toUpperCase(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: fontBold,
                fontFallback: fallbackFonts,
                fontSize: 20,
                color: _whiteColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
          pw.SizedBox(height: 30),

          // Contact Section
          _sidebarContactItem(
            icon: 'phone',
            text: user.phone.isEmpty ? '+00 000 000 0000' : user.phone,
            fontRegular: fontRegular,
            fallbackFonts: fallbackFonts,
          ),
          pw.SizedBox(height: 8),
          _sidebarContactItem(
            icon: 'email',
            text: user.email.isEmpty ? 'email@domain.com' : user.email,
            fontRegular: fontRegular,
            fallbackFonts: fallbackFonts,
          ),
          pw.SizedBox(height: 8),
          if (user.locations.isNotEmpty)
            _sidebarContactItem(
              icon: 'location',
              text: user.locations.join(', '),
              fontRegular: fontRegular,
              fallbackFonts: fallbackFonts,
            ),
          pw.SizedBox(height: 30),

          // Languages Section
          _sidebarSectionTitle(
            title: labels.languages,
            fontBold: fontBold,
            fallbackFonts: fallbackFonts,
          ),
          pw.SizedBox(height: 10),
          ...user.languages.map(
            (lang) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 6,
                    height: 6,
                    decoration: const pw.BoxDecoration(
                      color: _accentColor,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    lang,
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontFallback: fallbackFonts,
                      fontSize: 10,
                      color: _whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 25),

          // Hobbies/Awards Section (using awards or certifications)
          if (user.awards.isNotEmpty || user.certifications.isNotEmpty) ...[
            _sidebarSectionTitle(
              title: labels.certifications,
              fontBold: fontBold,
              fallbackFonts: fallbackFonts,
            ),
            pw.SizedBox(height: 10),
            ...(user.awards.isNotEmpty ? user.awards : user.certifications)
                .take(5)
                .map(
                  (item) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 6,
                          height: 6,
                          margin: const pw.EdgeInsets.only(top: 3),
                          decoration: const pw.BoxDecoration(
                            color: _accentColor,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Text(
                            item,
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontFallback: fallbackFonts,
                              fontSize: 9,
                              color: _whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  pw.Widget _sidebarContactItem({
    required String icon,
    required String text,
    required pw.Font fontRegular,
    required List<pw.Font> fallbackFonts,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 20,
          height: 20,
          decoration: const pw.BoxDecoration(
            color: _accentColor,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              icon == 'phone'
                  ? 'T'
                  : icon == 'email'
                  ? '@'
                  : 'L',
              style: pw.TextStyle(
                fontSize: 10,
                color: _whiteColor,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            text,
            style: pw.TextStyle(
              font: fontRegular,
              fontFallback: fallbackFonts,
              fontSize: 9,
              color: _whiteColor,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _sidebarSectionTitle({
    required String title,
    required pw.Font fontBold,
    required List<pw.Font> fallbackFonts,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _accentColor, width: 2)),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          font: fontBold,
          fontFallback: fallbackFonts,
          fontSize: 12,
          color: _accentColor,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// White main content area
  pw.Widget _buildMainContent({
    required CvUser user,
    required pw.Font fontBold,
    required pw.Font fontRegular,
    required List<pw.Font> fallbackFonts,
    required CvPdfLabels labels,
    required bool isRtl,
  }) {
    final jobValue = user.jobTitle.isEmpty
        ? labels.jobPlaceholder
        : user.jobTitle;

    return pw.Expanded(
      child: pw.Container(
        color: _whiteColor,
        padding: const pw.EdgeInsets.all(25),
        child: pw.Column(
          crossAxisAlignment: isRtl
              ? pw.CrossAxisAlignment.end
              : pw.CrossAxisAlignment.start,
          children: [
            // Summary Section
            _mainSectionTitle(
              title: labels.summary,
              fontBold: fontBold,
              fallbackFonts: fallbackFonts,
              isRtl: isRtl,
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              user.about.isEmpty
                  ? 'Describe in a few lines your career path, your key skills for the position and your career goals.'
                  : user.about,
              textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
              style: pw.TextStyle(
                font: fontRegular,
                fontFallback: fallbackFonts,
                fontSize: 9,
                color: _textGrey,
                lineSpacing: 3,
              ),
            ),
            pw.SizedBox(height: 20),

            // Experience Section
            _mainSectionTitle(
              title: labels.workExperience,
              fontBold: fontBold,
              fallbackFonts: fallbackFonts,
              isRtl: isRtl,
            ),
            pw.SizedBox(height: 8),
            ...user.experience
                .take(3)
                .map(
                  (exp) => _experienceItem(
                    title: jobValue,
                    description: exp,
                    fontBold: fontBold,
                    fontRegular: fontRegular,
                    fallbackFonts: fallbackFonts,
                    isRtl: isRtl,
                  ),
                ),
            pw.SizedBox(height: 15),

            // Education Section
            _mainSectionTitle(
              title: labels.education,
              fontBold: fontBold,
              fallbackFonts: fallbackFonts,
              isRtl: isRtl,
            ),
            pw.SizedBox(height: 8),
            ...user.education
                .take(2)
                .map(
                  (edu) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 5,
                          height: 5,
                          margin: const pw.EdgeInsets.only(top: 4),
                          decoration: const pw.BoxDecoration(
                            color: _accentColor,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Text(
                            edu,
                            textAlign: isRtl
                                ? pw.TextAlign.right
                                : pw.TextAlign.left,
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontFallback: fallbackFonts,
                              fontSize: 9,
                              color: _textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            pw.SizedBox(height: 15),

            // Skills Section (Grid layout)
            _mainSectionTitle(
              title: labels.skills,
              fontBold: fontBold,
              fallbackFonts: fallbackFonts,
              isRtl: isRtl,
            ),
            pw.SizedBox(height: 8),
            _skillsGrid(
              skills: user.skills,
              fontRegular: fontRegular,
              fallbackFonts: fallbackFonts,
            ),
            pw.SizedBox(height: 15),

            // Courses Section
            if (user.courses.isNotEmpty) ...[
              _mainSectionTitle(
                title: labels.courses,
                fontBold: fontBold,
                fallbackFonts: fallbackFonts,
                isRtl: isRtl,
              ),
              pw.SizedBox(height: 8),
              ...user.courses
                  .take(3)
                  .map(
                    (course) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 5,
                            height: 5,
                            margin: const pw.EdgeInsets.only(top: 4),
                            decoration: const pw.BoxDecoration(
                              color: _accentColor,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Text(
                              course,
                              textAlign: isRtl
                                  ? pw.TextAlign.right
                                  : pw.TextAlign.left,
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontFallback: fallbackFonts,
                                fontSize: 9,
                                color: _textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _mainSectionTitle({
    required String title,
    required pw.Font fontBold,
    required List<pw.Font> fallbackFonts,
    required bool isRtl,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _accentColor, width: 2)),
      ),
      child: pw.Text(
        title.toUpperCase(),
        textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          font: fontBold,
          fontFallback: fallbackFonts,
          fontSize: 13,
          color: _accentColor,
          letterSpacing: 1,
        ),
      ),
    );
  }

  pw.Widget _experienceItem({
    required String title,
    required String description,
    required pw.Font fontBold,
    required pw.Font fontRegular,
    required List<pw.Font> fallbackFonts,
    required bool isRtl,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: isRtl
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              font: fontBold,
              fontFallback: fallbackFonts,
              fontSize: 10,
              color: _textDark,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 5,
                height: 5,
                margin: const pw.EdgeInsets.only(top: 4),
                decoration: const pw.BoxDecoration(
                  color: _accentColor,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  description,
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontFallback: fallbackFonts,
                    fontSize: 9,
                    color: _textGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _skillsGrid({
    required List<String> skills,
    required pw.Font fontRegular,
    required List<pw.Font> fallbackFonts,
  }) {
    if (skills.isEmpty) return pw.SizedBox.shrink();

    final rows = <pw.Widget>[];
    for (var i = 0; i < skills.length; i += 2) {
      final row = pw.Row(
        children: [
          pw.Expanded(
            child: _skillItem(
              skill: skills[i],
              fontRegular: fontRegular,
              fallbackFonts: fallbackFonts,
            ),
          ),
          if (i + 1 < skills.length)
            pw.Expanded(
              child: _skillItem(
                skill: skills[i + 1],
                fontRegular: fontRegular,
                fallbackFonts: fallbackFonts,
              ),
            )
          else
            pw.Expanded(child: pw.SizedBox()),
        ],
      );
      rows.add(row);
    }

    return pw.Column(children: rows);
  }

  pw.Widget _skillItem({
    required String skill,
    required pw.Font fontRegular,
    required List<pw.Font> fallbackFonts,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Container(
            width: 5,
            height: 5,
            decoration: const pw.BoxDecoration(
              color: _accentColor,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Text(
              skill,
              style: pw.TextStyle(
                font: fontRegular,
                fontFallback: fallbackFonts,
                fontSize: 9,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<pw.ImageProvider?> _loadImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    final file = File(imagePath);
    if (!file.existsSync()) return null;
    final bytes = await file.readAsBytes();
    return pw.MemoryImage(bytes);
  }

  Future<pw.Font> _loadArabicFontRegular() async {
    final bytes = await rootBundle.load(
      'assets/fonts/NotoSansArabic-Regular.ttf',
    );
    return pw.Font.ttf(bytes);
  }

  Future<pw.Font> _loadArabicFontExtraBold() async {
    final bytes = await rootBundle.load(
      'assets/fonts/NotoSansArabic-ExtraBold.ttf',
    );
    return pw.Font.ttf(bytes);
  }

  Future<pw.Font> _loadArabicFontRegularSafe() async {
    try {
      return await _loadArabicFontRegular();
    } catch (error) {
      debugPrint('PDF font load failed (regular): $error');
      return pw.Font.helvetica();
    }
  }

  Future<pw.Font> _loadArabicFontExtraBoldSafe() async {
    try {
      return await _loadArabicFontExtraBold();
    } catch (error) {
      debugPrint('PDF font load failed (extra-bold): $error');
      return pw.Font.helveticaBold();
    }
  }
}

class CvPdfLabels {
  const CvPdfLabels({
    required this.summary,
    required this.education,
    required this.certifications,
    required this.workExperience,
    required this.contact,
    required this.skills,
    required this.courses,
    required this.references,
    required this.languages,
    required this.namePlaceholder,
    required this.jobPlaceholder,
    required this.isRtl,
  });

  final String summary;
  final String education;
  final String certifications;
  final String workExperience;
  final String contact;
  final String skills;
  final String courses;
  final String references;
  final String languages;
  final String namePlaceholder;
  final String jobPlaceholder;
  final bool isRtl;

  factory CvPdfLabels.fromLocalizations(AppLocalizations l) {
    return CvPdfLabels(
      summary: l.t('summary'),
      education: l.t('education'),
      certifications: l.t('certifications'),
      workExperience: l.t('workExperience'),
      contact: l.t('contact'),
      skills: l.t('skills'),
      courses: l.t('courses'),
      references: l.t('references'),
      languages: l.t('languages'),
      namePlaceholder: l.t('namePlaceholder'),
      jobPlaceholder: l.t('jobPlaceholder'),
      isRtl: l.locale.languageCode == 'ar',
    );
  }
}
