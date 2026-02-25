import 'cv_user.dart';

/// CV Language options
enum CvLanguage {
  arabic('ar', 'العربية'),
  english('en', 'English');

  const CvLanguage(this.code, this.displayName);
  final String code;
  final String displayName;

  static CvLanguage fromCode(String? code) {
    return CvLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => CvLanguage.arabic,
    );
  }
}

/// Represents a single CV document that can be created by a user.
/// A user can have multiple CVs but only one can be active at a time.
class CvDocument {
  const CvDocument({
    required this.id,
    required this.userId,
    required this.title,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.email,
    required this.phone,
    required this.locations,
    required this.jobTitle,
    required this.cvType,
    required this.selectedTemplate,
    required this.about,
    required this.skills,
    required this.certifications,
    required this.courses,
    required this.awards,
    required this.references,
    required this.experience,
    required this.education,
    required this.languages,
    required this.theme,
    required this.cvLanguage,
  });

  final String id;
  final String userId;
  final String title;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String email;
  final String phone;
  final List<String> locations;
  final String jobTitle;
  final String cvType;
  final String selectedTemplate;
  final String about;
  final List<String> skills;
  final List<String> certifications;
  final List<String> courses;
  final List<String> awards;
  final List<String> references;
  final List<String> experience;
  final List<String> education;
  final List<String> languages;
  final String theme;
  final CvLanguage cvLanguage;

  CvDocument copyWith({
    String? id,
    String? userId,
    String? title,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? email,
    String? phone,
    List<String>? locations,
    String? jobTitle,
    String? cvType,
    String? selectedTemplate,
    String? about,
    List<String>? skills,
    List<String>? certifications,
    List<String>? courses,
    List<String>? awards,
    List<String>? references,
    List<String>? experience,
    List<String>? education,
    List<String>? languages,
    String? theme,
    CvLanguage? cvLanguage,
  }) {
    return CvDocument(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      locations: locations ?? this.locations,
      jobTitle: jobTitle ?? this.jobTitle,
      cvType: cvType ?? this.cvType,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      about: about ?? this.about,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      courses: courses ?? this.courses,
      awards: awards ?? this.awards,
      references: references ?? this.references,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      theme: theme ?? this.theme,
      cvLanguage: cvLanguage ?? this.cvLanguage,
    );
  }

  factory CvDocument.fromMap(String id, Map<String, dynamic> map) {
    List<String> toList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return CvDocument(
      id: id,
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'سيرتي الذاتية',
      isActive: map['isActive'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(),
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      locations: toList(map['locations']),
      jobTitle: map['jobTitle']?.toString() ?? '',
      cvType: map['cvType']?.toString() ?? 'professional',
      selectedTemplate: map['selectedTemplate']?.toString() ?? 'modern',
      about: map['about']?.toString() ?? '',
      skills: toList(map['skills']),
      certifications: toList(map['certifications']),
      courses: toList(map['courses']),
      awards: toList(map['awards']),
      references: toList(map['references']),
      experience: toList(map['experience']),
      education: toList(map['education']),
      languages: toList(map['languages']),
      theme: map['theme']?.toString() ?? 'system',
      cvLanguage: CvLanguage.fromCode(map['cvLanguage']?.toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'name': name,
      'email': email,
      'phone': phone,
      'locations': locations,
      'jobTitle': jobTitle,
      'cvType': cvType,
      'selectedTemplate': selectedTemplate,
      'about': about,
      'skills': skills,
      'certifications': certifications,
      'courses': courses,
      'awards': awards,
      'references': references,
      'experience': experience,
      'education': education,
      'languages': languages,
      'theme': theme,
      'cvLanguage': cvLanguage.code,
    };
  }

  /// Creates a new empty CV document for a user
  factory CvDocument.empty({
    required String userId,
    required String userName,
    required String userEmail,
    String title = 'سيرتي الذاتية',
    bool isActive = false,
    CvLanguage cvLanguage = CvLanguage.arabic,
  }) {
    final now = DateTime.now();
    final isArabic = cvLanguage == CvLanguage.arabic;
    final resolvedTitle = title.isNotEmpty
        ? title
        : (isArabic ? 'سيرتي الذاتية' : 'My Professional CV');
    return CvDocument(
      id: '',
      userId: userId,
      title: resolvedTitle,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
      name: userName,
      email: userEmail,
      phone: isArabic ? '079 123 4567' : '+962 79 123 4567',
      locations: isArabic
          ? const [
              'عمّان - الأردن',
              'الزرقاء - الأردن',
              'إربد - الأردن',
              'العقبة - الأردن',
              'السلط - الأردن',
            ]
          : const [
              'Amman, Jordan',
              'Zarqa, Jordan',
              'Irbid, Jordan',
              'Aqaba, Jordan',
              'Salt, Jordan',
            ],
      jobTitle: isArabic ? 'مطور تطبيقات Flutter' : 'Flutter App Developer',
      cvType: 'professional',
      selectedTemplate: 'modern',
      about: isArabic
          ? 'مطور Flutter بخبرة في بناء تطبيقات موبايل عالية الجودة، والتركيز على الأداء وتجربة المستخدم.'
          : 'Flutter developer with experience building high-quality mobile apps, focused on performance and user experience.',
      skills: isArabic
          ? const [
              'Flutter',
              'Dart',
              'Firebase',
              'REST APIs',
              'Git',
              'Clean Architecture',
              'State Management (Provider)',
              'UI/UX Basics',
              'Riverpod',
              'CI/CD Basics',
              'Unit Testing',
              'Figma Handoff',
            ]
          : const [
              'Flutter',
              'Dart',
              'Firebase',
              'REST APIs',
              'Git',
              'Clean Architecture',
              'State Management (Provider)',
              'UI/UX Basics',
              'Riverpod',
              'CI/CD Basics',
              'Unit Testing',
              'Figma Handoff',
            ],
      certifications: isArabic
          ? const [
              'Google Flutter Developer (أساسي)',
              'مبادئ هندسة البرمجيات',
              'أساسيات أمن التطبيقات',
            ]
          : const [
              'Google Flutter Developer (Foundation)',
              'Software Engineering Fundamentals',
              'Application Security Basics',
            ],
      courses: isArabic
          ? const [
              'معسكر تطوير تطبيقات Flutter',
              'دورة تصميم قواعد البيانات',
              'أساسيات واجهات المستخدم',
              'بناء واجهات متجاوبة',
              'إدارة الحالة المتقدمة',
            ]
          : const [
              'Flutter Mobile Development Bootcamp',
              'Database Design Fundamentals',
              'UI Fundamentals',
              'Responsive UI Layouts',
              'Advanced State Management',
            ],
      awards: isArabic
          ? const [
              'أفضل مشروع تخرج',
              'مركز أول في هاكاثون جامعي',
              'شهادة تميز أكاديمي',
            ]
          : const [
              'Best Graduation Project',
              '1st Place in University Hackathon',
              'Academic Excellence Award',
            ],
      references: isArabic
          ? const [
              'متاحة عند الطلب',
              'م. أحمد خالد - مدير تقني',
              'م. سارة عادل - مديرة مشروع',
            ]
          : const [
              'Available upon request',
              'Eng. Ahmad Khaled - Tech Lead',
              'Ms. Sara Adel - Project Manager',
            ],
      experience: isArabic
          ? const [
              'مطوّر Flutter | شركة تقنية ناشئة | 2023 - الآن',
              'مطور تطبيقات موبايل (متدرب) | 2022 - 2023',
              'مشاريع حرّة | تطوير تطبيقات أعمال صغيرة | 2021 - 2022',
              'تطوير تطبيق حجوزات | عقد مستقل | 2021',
            ]
          : const [
              'Flutter Developer | Startup Tech Company | 2023 - Present',
              'Mobile Developer Intern | 2022 - 2023',
              'Freelance Projects | Small Business Apps | 2021 - 2022',
              'Booking App Development | Contract | 2021',
            ],
      education: isArabic
          ? const [
              'بكالوريوس علوم الحاسوب | جامعة اليرموك | 2019 - 2023',
              'دبلوم تطوير تطبيقات موبايل | 2018 - 2019',
              'دورات تخصصية في Flutter وFirebase | 2020',
            ]
          : const [
              'B.Sc. Computer Science | Yarmouk University | 2019 - 2023',
              'Diploma in Mobile App Development | 2018 - 2019',
              'Specialized Courses in Flutter & Firebase | 2020',
            ],
      languages: isArabic
          ? const [
              'العربية (لغة أم)',
              'الإنجليزية (جيد جداً)',
              'الفرنسية (أساسي)',
              'التركية (مبتدئ)',
            ]
          : const [
              'Arabic (Native)',
              'English (Very Good)',
              'French (Basic)',
              'Turkish (Beginner)',
            ],
      theme: 'dark',
      cvLanguage: cvLanguage,
    );
  }

  /// Convert to legacy CvUser format for compatibility with existing screens
  CvUser toCvUser() {
    return CvUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      locations: locations,
      jobTitle: jobTitle,
      cvType: cvType,
      selectedTemplate: selectedTemplate,
      about: about,
      skills: skills,
      certifications: certifications,
      courses: courses,
      awards: awards,
      references: references,
      experience: experience,
      education: education,
      languages: languages,
      theme: theme,
    );
  }

  /// Create CvDocument from CvUser (for migration/update)
  factory CvDocument.fromCvUser(
    CvUser user, {
    required String docId,
    required String title,
    required bool isActive,
    CvLanguage cvLanguage = CvLanguage.arabic,
  }) {
    final now = DateTime.now();
    return CvDocument(
      id: docId,
      userId: user.id,
      title: title,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
      name: user.name,
      email: user.email,
      phone: user.phone,
      locations: user.locations,
      jobTitle: user.jobTitle,
      cvType: user.cvType,
      selectedTemplate: user.selectedTemplate,
      about: user.about,
      skills: user.skills,
      certifications: user.certifications,
      courses: user.courses,
      awards: user.awards,
      references: user.references,
      experience: user.experience,
      education: user.education,
      languages: user.languages,
      theme: user.theme,
      cvLanguage: cvLanguage,
    );
  }
}
