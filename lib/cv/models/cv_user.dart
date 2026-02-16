class CvUser {
  const CvUser({
    required this.id,
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
  });

  final String id;
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

  CvUser copyWith({
    String? id,
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
  }) {
    return CvUser(
      id: id ?? this.id,
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
    );
  }

  factory CvUser.fromMap(String id, Map<String, dynamic> map) {
    List<String> toList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return CvUser(
      id: id,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
    };
  }
}
