import '../utils/app_constants.dart';
import 'storage_service.dart';

class FilterService {
  FilterService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  final StorageService _storageService;

  Future<List<Map<String, dynamic>>> applyFilters({
    List<String>? subjectLabels,
    Map<String, List<Map<String, String>>>? timeSlots,
  }) async {
    final tutors = await _storageService.getAllTutors();
    final filteredBySubject = _filterBySubject(tutors, subjectLabels);
    return _filterByTime(filteredBySubject, timeSlots);
  }

  List<Map<String, dynamic>> _filterBySubject(
    List<Map<String, dynamic>> tutors,
    List<String>? subjectLabels,
  ) {
    if (subjectLabels == null || subjectLabels.isEmpty) {
      return tutors;
    }
    final List<_SubjectQuery> queries = subjectLabels
        .map(_parseSubjectLabel)
        .where((query) => query.subject.isNotEmpty)
        .toList();
    if (queries.isEmpty) {
      return tutors;
    }
    return tutors.where((tutor) {
      final List<Map<String, dynamic>> subjects =
          (tutor['subjects'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
      if (subjects.isEmpty) {
        return false;
      }
      return queries.every((query) {
        return subjects.any((entry) {
          final String entrySubject = (entry['subject'] as String? ?? '').trim();
          if (entrySubject != query.subject) {
            return false;
          }
          if (query.level == null || query.level!.isEmpty) {
            return true;
          }
          final String? entryLevel = (entry['level'] as String?)?.trim();
          return entryLevel == query.level;
        });
      });
    }).toList();
  }

  List<Map<String, dynamic>> _filterByTime(
    List<Map<String, dynamic>> tutors,
    Map<String, List<Map<String, String>>>? timeSlots,
  ) {
    if (timeSlots == null || timeSlots.isEmpty) {
      return tutors;
    }
    return tutors.where((tutor) {
      final schedule = Map<String, dynamic>.from(tutor['schedule'] as Map? ?? {});
      for (final entry in timeSlots.entries) {
        final day = entry.key;
        final slots = entry.value;
        final blocks = (schedule[day] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        for (final slot in slots) {
          for (final block in blocks) {
            if (_isOverlap(slot['startTime']!, slot['endTime']!,
                block['startTime'] as String, block['endTime'] as String)) {
              return false;
            }
          }
        }
      }
      return true;
    }).toList();
  }

  bool _isOverlap(String s1, String e1, String s2, String e2) {
    final start1 = _timeToMinutes(s1);
    final end1 = _timeToMinutes(e1);
    final start2 = _timeToMinutes(s2);
    final end2 = _timeToMinutes(e2);
    return start1 < end2 && end1 > start2;
  }

  int _timeToMinutes(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]) ?? AppConstants.scheduleStartHour;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  _SubjectQuery _parseSubjectLabel(String label) {
    final String trimmed = label.trim();
    if (trimmed.isEmpty || trimmed == 'ทั้งหมด') {
      return const _SubjectQuery('', null);
    }
    final int openIndex = trimmed.indexOf('(');
    final int closeIndex = trimmed.lastIndexOf(')');
    if (openIndex != -1 && closeIndex > openIndex) {
      final String subject = trimmed.substring(0, openIndex).trim();
      final String level = trimmed.substring(openIndex + 1, closeIndex).trim();
      return _SubjectQuery(subject, level.isEmpty ? null : level);
    }
    final int altOpen = trimmed.indexOf('（');
    final int altClose = trimmed.lastIndexOf('）');
    if (altOpen != -1 && altClose > altOpen) {
      final String subject = trimmed.substring(0, altOpen).trim();
      final String level = trimmed.substring(altOpen + 1, altClose).trim();
      return _SubjectQuery(subject, level.isEmpty ? null : level);
    }
    return _SubjectQuery(trimmed, null);
  }
}

class _SubjectQuery {
  const _SubjectQuery(this.subject, this.level);

  final String subject;
  final String? level;
}
