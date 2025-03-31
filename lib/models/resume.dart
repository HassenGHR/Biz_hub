class PersonalInfo {
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  String title = '';
  String summary = '';
  String? photoUrl;

  PersonalInfo();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'title': title,
      'summary': summary,
      'photoUrl': photoUrl,
    };
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    PersonalInfo info = PersonalInfo();
    info.name = json['name'] ?? '';
    info.email = json['email'] ?? '';
    info.phone = json['phone'] ?? '';
    info.address = json['address'] ?? '';
    info.title = json['title'] ?? '';
    info.summary = json['summary'] ?? '';
    info.photoUrl = json['photoUrl'];
    return info;
  }
}

class Education {
  String institution = '';
  String degree = '';
  String startDate = '';
  String endDate = '';
  String description = '';
  Education();

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    Education education = Education();
    education.institution = json['institution'] ?? '';
    education.degree = json['degree'] ?? '';
    education.startDate = json['startDate'] ?? '';
    education.endDate = json['endDate'] ?? '';
    education.description = json['description'] ?? '';
    return education;
  }
}

class Experience {
  String company = '';
  String title = '';
  String startDate = '';
  String endDate = '';
  String description = '';
  Experience();

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  factory Experience.fromJson(Map<String, dynamic> json) {
    Experience experience = Experience();
    experience.company = json['company'] ?? '';
    experience.title = json['title'] ?? '';
    experience.startDate = json['startDate'] ?? '';
    experience.endDate = json['endDate'] ?? '';
    experience.description = json['description'] ?? '';
    return experience;
  }
}

class ResumeData {
  String id = '';
  String templateId = 'modern';
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  PersonalInfo personalInfo;
  List<Education> education;
  List<Experience> experience;
  List<String> skills;

  ResumeData({
    this.id = '',
    required this.personalInfo,
    required this.education,
    required this.experience,
    required this.skills,
    this.templateId = 'modern',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'personalInfo': personalInfo.toJson(),
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'skills': skills,
    };
  }

  factory ResumeData.fromJson(Map<dynamic, dynamic> json) {
    return ResumeData(
      id: json['id'] ?? '',
      templateId: json['templateId'] ?? 'modern',
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      education: (json['education'] as List?)
              ?.map((e) => Education.fromJson(e))
              .toList() ??
          [],
      experience: (json['experience'] as List?)
              ?.map((e) => Experience.fromJson(e))
              .toList() ??
          [],
      skills:
          (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
    )
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String);
  }
}
