import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/cv_user.dart';

/// Arabic CV PDF Builder - Matches the modern Arabic CV design
class ArabicCvPdfBuilder {
  // Colors matching the Arabic CV design
  static const _sidebarColor = PdfColor.fromInt(0xFF374151); // Dark grey
  static const _headerColor = PdfColor.fromInt(0xFF1E3A5F); // Dark blue header
  static const _accentColor = PdfColor.fromInt(0xFF3B82F6); // Blue accent
  static const _whiteColor = PdfColors.white;
  static const _textDark = PdfColor.fromInt(0xFF1F2937);
  static const _textGrey = PdfColor.fromInt(0xFF6B7280);
  static const _dividerColor = PdfColor.fromInt(0xFFE5E7EB);

  Future<Uint8List> buildArabicPdf(
    CvUser user, {
    String? imagePath,
    required ArabicCvLabels labels,
  }) async {
    final doc = pw.Document();

    // Load Arabic fonts
    final arabicRegular = await _loadArabicFontRegular();
    final arabicBold = await _loadArabicFontBold();

    final imageProvider = await _loadImage(imagePath);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return [
            pw.Partitions(
              children: [
                pw.Partition(
                  child: pw.Column(
                    children: [
                      _buildMainContent(
                        user: user,
                        fontBold: arabicBold,
                        fontRegular: arabicRegular,
                        labels: labels,
                      ),
                    ],
                  ),
                ),
                pw.Partition(
                  width: 220,
                  child: pw.Column(
                    children: [
                      _buildSidebar(
                        user: user,
                        imageProvider: imageProvider,
                        fontBold: arabicBold,
                        fontRegular: arabicRegular,
                        labels: labels,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// Grey sidebar with photo, contact, profile, languages, hobbies
  pw.Widget _buildSidebar({
    required CvUser user,
    required pw.ImageProvider? imageProvider,
    required pw.Font fontBold,
    required pw.Font fontRegular,
    required ArabicCvLabels labels,
  }) {
    return pw.Container(
      width: 220,
      color: _sidebarColor,
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // Profile Photo
          pw.Center(
            child: pw.Container(
              width: 130,
              height: 160,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _whiteColor, width: 3),
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
                        user.name.isNotEmpty ? user.name[0] : '?',
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
          pw.SizedBox(height: 25),

          // Contact Info
          _contactItem(
            icon: 'phone',
            text: user.phone.isEmpty ? '+974 00000000' : user.phone,
            fontRegular: fontRegular,
          ),
          pw.SizedBox(height: 10),
          _contactItem(
            icon: 'email',
            text: user.email.isEmpty ? 'example@gmail.com' : user.email,
            fontRegular: fontRegular,
          ),
          pw.SizedBox(height: 10),
          if (user.locations.isNotEmpty)
            _contactItem(
              icon: 'location',
              text: user.locations.first,
              fontRegular: fontRegular,
            ),
          pw.SizedBox(height: 30),

          // Profile/About Section
          _sidebarSection(title: labels.profile, fontBold: fontBold),
          pw.SizedBox(height: 10),
          pw.Text(
            user.about.isEmpty
                ? 'اكتب نبذة مختصرة عن نفسك وخبراتك المهنية والشخصية.'
                : user.about,
            textAlign: pw.TextAlign.right,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 9,
              color: _whiteColor,
              lineSpacing: 4,
            ),
          ),
          pw.SizedBox(height: 25),

          // Languages Section
          _sidebarSection(title: labels.languages, fontBold: fontBold),
          pw.SizedBox(height: 10),
          ...user.languages.map(
            (lang) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
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
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 10,
                      color: _whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 25),

          // Hobbies/Interests Section (using references or awards)
          _sidebarSection(title: labels.hobbies, fontBold: fontBold),
          pw.SizedBox(height: 10),
          ...(user.references.isNotEmpty ? user.references : _defaultHobbies())
              .map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
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
                          textAlign: pw.TextAlign.right,
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                            font: fontRegular,
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
      ),
    );
  }

  List<String> _defaultHobbies() {
    return ['القراءة', 'الرياضة', 'السباحة', 'السفر'];
  }

  pw.Widget _contactItem({
    required String icon,
    required String text,
    required pw.Font fontRegular,
  }) {
    String iconText;
    switch (icon) {
      case 'phone':
        iconText = 'T';
        break;
      case 'email':
        iconText = '@';
        break;
      case 'location':
        iconText = 'L';
        break;
      default:
        iconText = '*';
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 22,
          height: 22,
          decoration: const pw.BoxDecoration(
            color: _accentColor,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              iconText,
              style: const pw.TextStyle(fontSize: 10, color: _whiteColor),
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            text,
            textAlign: pw.TextAlign.right,
            textDirection: pw.TextDirection.ltr, // Keep numbers LTR
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 9,
              color: _whiteColor,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _sidebarSection({
    required String title,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _accentColor, width: 2)),
      ),
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.right,
        textDirection: pw.TextDirection.rtl,
        style: pw.TextStyle(font: fontBold, fontSize: 13, color: _accentColor),
      ),
    );
  }

  /// Main content area (white background)
  pw.Widget _buildMainContent({
    required CvUser user,
    required pw.Font fontBold,
    required pw.Font fontRegular,
    required ArabicCvLabels labels,
  }) {
    return pw.Column(
      children: [
        // Blue header with name and job title
        pw.Container(
          width: double.infinity,
          color: _headerColor,
          padding: const pw.EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                user.name.isEmpty ? 'اسمك الكامل' : user.name,
                textAlign: pw.TextAlign.right,
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 28,
                  color: _whiteColor,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                user.jobTitle.isEmpty ? 'المسمى الوظيفي' : user.jobTitle,
                textAlign: pw.TextAlign.right,
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 14,
                  color: _whiteColor,
                ),
              ),
            ],
          ),
        ),

        // White content area
        pw.Container(
          color: _whiteColor,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              // Education Section
              _mainSection(title: labels.education, fontBold: fontBold),
              pw.SizedBox(height: 10),
              ...user.education.map(
                (edu) => _bulletItem(text: edu, fontRegular: fontRegular),
              ),
              pw.SizedBox(height: 20),

              // Work Experience Section
              _mainSection(title: labels.workExperience, fontBold: fontBold),
              pw.SizedBox(height: 10),
              ...user.experience.map(
                (exp) => _bulletItem(text: exp, fontRegular: fontRegular),
              ),
              pw.SizedBox(height: 20),

              // Training Courses Section
              _mainSection(title: labels.courses, fontBold: fontBold),
              pw.SizedBox(height: 10),
              ...user.courses.map(
                (course) => _bulletItem(
                  text: course,
                  fontRegular: fontRegular,
                  small: true,
                ),
              ),
              pw.SizedBox(height: 20),

              // Achievements Section
              _mainSection(title: labels.achievements, fontBold: fontBold),
              pw.SizedBox(height: 10),
              ...user.awards.map(
                (award) => _bulletItem(
                  text: award,
                  fontRegular: fontRegular,
                  small: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _mainSection({required String title, required pw.Font fontBold}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _dividerColor, width: 1),
        ),
      ),
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.right,
        textDirection: pw.TextDirection.rtl,
        style: pw.TextStyle(font: fontBold, fontSize: 14, color: _textDark),
      ),
    );
  }

  pw.Widget _bulletItem({
    required String text,
    required pw.Font fontRegular,
    bool small = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
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
              text,
              textAlign: pw.TextAlign.right,
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: small ? 9 : 10,
                color: _textGrey,
                lineSpacing: 3,
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
    try {
      final bytes = await rootBundle.load(
        'assets/fonts/NotoSansArabic-Regular.ttf',
      );
      return pw.Font.ttf(bytes);
    } catch (e) {
      debugPrint('Failed to load Arabic regular font: $e');
      return pw.Font.helvetica();
    }
  }

  Future<pw.Font> _loadArabicFontBold() async {
    try {
      final bytes = await rootBundle.load(
        'assets/fonts/NotoSansArabic-ExtraBold.ttf',
      );
      return pw.Font.ttf(bytes);
    } catch (e) {
      debugPrint('Failed to load Arabic bold font: $e');
      return pw.Font.helveticaBold();
    }
  }
}

/// Labels for Arabic CV
class ArabicCvLabels {
  const ArabicCvLabels({
    required this.profile,
    required this.languages,
    required this.hobbies,
    required this.education,
    required this.workExperience,
    required this.courses,
    required this.achievements,
    required this.skills,
    required this.certifications,
  });

  final String profile;
  final String languages;
  final String hobbies;
  final String education;
  final String workExperience;
  final String courses;
  final String achievements;
  final String skills;
  final String certifications;

  /// Default Arabic labels
  factory ArabicCvLabels.arabic() {
    return const ArabicCvLabels(
      profile: 'بروفايل',
      languages: 'اللغات',
      hobbies: 'الهوايات',
      education: 'المؤهلات التعليمية',
      workExperience: 'خبرات العمل',
      courses: 'الدورات التدريبية',
      achievements: 'الإنجازات',
      skills: 'المهارات',
      certifications: 'الشهادات',
    );
  }
}
