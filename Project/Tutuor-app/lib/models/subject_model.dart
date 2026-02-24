class SubjectLevel {
  const SubjectLevel({
    required this.subject,
    this.level,
  });

  final String subject;
  final String? level;

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'level': level,
      };

  factory SubjectLevel.fromJson(Map<String, dynamic> json) {
    return SubjectLevel(
      subject: json['subject'] as String? ?? '',
      level: json['level'] as String?,
    );
  }
}

class Subject {
  const Subject({
    required this.subjectId,
    required this.subjectName,
    required this.levels,
  });

  final String subjectId;
  final String subjectName;
  final List<String> levels;

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      levels: (json['levels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'levels': levels,
      };
}
