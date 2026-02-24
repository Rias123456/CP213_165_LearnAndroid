class ScheduleBlock {
  const ScheduleBlock({
    required this.blockId,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.note,
  });

  final String blockId;
  final String startTime;
  final String endTime;
  final String type; // teaching or busy
  final String? note;

  factory ScheduleBlock.fromJson(Map<String, dynamic> json) {
    return ScheduleBlock(
      blockId: json['blockId'] as String? ?? json['id'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '08:00',
      endTime: json['endTime'] as String? ?? '08:30',
      type: json['type'] as String? ?? 'busy',
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blockId': blockId,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      if (note != null) 'note': note,
    };
  }

  ScheduleBlock copyWith({
    String? blockId,
    String? startTime,
    String? endTime,
    String? type,
    String? note,
  }) {
    return ScheduleBlock(
      blockId: blockId ?? this.blockId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }
}

class TimeSlot {
  const TimeSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  final String day;
  final String startTime;
  final String endTime;

  Map<String, dynamic> toJson() => {
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
      };

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      day: json['day'] as String? ?? 'saturday',
      startTime: json['startTime'] as String? ?? '08:00',
      endTime: json['endTime'] as String? ?? '08:30',
    );
  }

  TimeSlot normalized() {
    final startMinutes = _timeToMinutes(startTime);
    final endMinutes = _timeToMinutes(endTime);
    if (startMinutes <= endMinutes) {
      return this;
    }
    return TimeSlot(day: day, startTime: endTime, endTime: startTime);
  }

  static int _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }
}
