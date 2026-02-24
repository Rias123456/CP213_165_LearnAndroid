import 'package:cloud_firestore/cloud_firestore.dart';

import 'schedule_model.dart';
import 'subject_model.dart';

class Tutor {
  const Tutor({
    required this.tutorId,
    required this.realName,
    required this.nickname,
    required this.lineId,
    required this.phoneNumber,
    required this.currentActivity,
    required this.travelTime,
    required this.teachingCondition,
    required this.profileImageBase64,
    required this.subjects,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
  });

  final String tutorId;
  final String realName;
  final String nickname;
  final String lineId;
  final String phoneNumber;
  final String currentActivity;
  final String travelTime;
  final String teachingCondition;
  final String profileImageBase64;
  final List<SubjectLevel> subjects;
  final Map<String, List<ScheduleBlock>> schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Tutor.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return Tutor.fromJson(snapshot.id, data);
  }

  factory Tutor.fromJson(String id, Map<String, dynamic> json) {
    return Tutor(
      tutorId: id,
      realName: json['realName'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      lineId: json['lineId'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      currentActivity: json['currentActivity'] as String? ?? '',
      travelTime: json['travelTime'] as String? ?? '',
      teachingCondition: json['teachingCondition'] as String? ?? '',
      profileImageBase64: json['profileImageBase64'] as String? ?? '',
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map(
                (e) => SubjectLevel.fromJson(
                  Map<String, dynamic>.from(
                    e as Map<dynamic, dynamic>,
                  ),
                ),
              )
              .toList() ??
          const <SubjectLevel>[],
      schedule: _parseSchedule(json['schedule'] as Map<String, dynamic>?),
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'realName': realName,
      'nickname': nickname,
      'lineId': lineId,
      'phoneNumber': phoneNumber,
      'currentActivity': currentActivity,
      'travelTime': travelTime,
      'teachingCondition': teachingCondition,
      'profileImageBase64': profileImageBase64,
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'schedule': schedule.map((key, value) => MapEntry(
            key,
            value.map((block) => block.toJson()).toList(),
          )),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Tutor copyWith({
    String? realName,
    String? nickname,
    String? lineId,
    String? phoneNumber,
    String? currentActivity,
    String? travelTime,
    String? profileImageBase64,
    String? teachingCondition,
    List<SubjectLevel>? subjects,
    Map<String, List<ScheduleBlock>>? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tutor(
      tutorId: tutorId,
      realName: realName ?? this.realName,
      nickname: nickname ?? this.nickname,
      lineId: lineId ?? this.lineId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currentActivity: currentActivity ?? this.currentActivity,
      travelTime: travelTime ?? this.travelTime,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      teachingCondition: teachingCondition ?? this.teachingCondition,
      subjects: subjects ?? this.subjects,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

DateTime _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

Map<String, List<ScheduleBlock>> _parseSchedule(Map<String, dynamic>? raw) {
  final defaultMap = {
    'saturday': <ScheduleBlock>[],
    'sunday': <ScheduleBlock>[],
    'monday': <ScheduleBlock>[],
    'tuesday': <ScheduleBlock>[],
    'wednesday': <ScheduleBlock>[],
    'thursday': <ScheduleBlock>[],
    'friday': <ScheduleBlock>[],
  };

  if (raw == null) {
    return defaultMap;
  }

  final parsed = <String, List<ScheduleBlock>>{};
  for (final entry in raw.entries) {
    parsed[entry.key] = (entry.value as List<dynamic>?)
            ?.map(
              (e) => ScheduleBlock.fromJson(
                Map<String, dynamic>.from(
                  e as Map<dynamic, dynamic>,
                ),
              ),
            )
            .toList() ??
        <ScheduleBlock>[];
  }

  return defaultMap..addAll(parsed);
}
