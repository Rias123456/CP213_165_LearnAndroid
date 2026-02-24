import 'package:flutter/material.dart';

import '../utils/constants.dart';

class SubjectDropdown extends StatelessWidget {
  const SubjectDropdown({
    super.key,
    required this.selectedSubject,
    required this.selectedLevel,
    required this.onSubjectChanged,
    required this.onLevelChanged,
  });

  final String? selectedSubject;
  final String? selectedLevel;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<String?> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    final subjects = AppConstants.subjects;
    final levels = _levelsForSubject(selectedSubject);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedSubject,
          decoration: const InputDecoration(labelText: 'วิชา'),
          items: [
            const DropdownMenuItem(value: 'ทั้งหมด', child: Text('ทั้งหมด')),
            ...subjects.map(
              (subject) => DropdownMenuItem(
                value: subject['name'] as String,
                child: Text(subject['name'] as String),
              ),
            ),
          ],
          onChanged: (value) {
            onSubjectChanged(value);
            onLevelChanged(null);
          },
        ),
        if (levels != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: DropdownButtonFormField<String>(
              value: selectedLevel ?? (levels.contains('ทั้งหมด') ? 'ทั้งหมด' : levels.first),
              decoration: const InputDecoration(labelText: 'ระดับชั้น'),
              items: levels
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    ),
                  )
                  .toList(),
              onChanged: onLevelChanged,
            ),
          ),
      ],
    );
  }

  List<String>? _levelsForSubject(String? subjectName) {
    if (subjectName == null || subjectName == 'ทั้งหมด') {
      return null;
    }
    final map = AppConstants.subjects.firstWhere(
      (element) => element['name'] == subjectName,
      orElse: () => <String, dynamic>{},
    );
    final levels = map['levels'] as List<dynamic>?;
    if (levels == null || levels.isEmpty) {
      return null;
    }
    return ['ทั้งหมด', ...levels.cast<String>()];
  }
}
