import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../models/tutor_model.dart';
import '../utils/app_constants.dart';

class TutorCard extends StatelessWidget {
  const TutorCard({
    super.key,
    required this.tutor,
    this.onViewSchedule,
  });

  final Tutor tutor;
  final VoidCallback? onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectTexts = tutor.subjects.isEmpty
        ? 'ยังไม่ระบุ'
        : tutor.subjects
            .map((SubjectLevel s) =>
                s.level == null ? s.subject : '${s.subject} (${s.level})')
            .join(', ');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ติวเตอร์${tutor.nickname}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _buildRow(Icons.school, 'วิชาที่สอน', subjectTexts),
            const SizedBox(height: 6),
            _buildRow(Icons.phone_android, 'เบอร์โทร', tutor.phoneNumber),
            const SizedBox(height: 6),
            _buildRow(Icons.chat_bubble_outline, 'Line', tutor.lineId),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: onViewSchedule,
                child: const Text('ดูตาราง'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.darkPurple,
            ),
          ),
        ),
      ],
    );
  }
}
