import 'package:flutter/material.dart';

import '../models/schedule_model.dart';
import '../utils/constants.dart';
import 'schedule_grid.dart';

class TimeSelector extends StatelessWidget {
  const TimeSelector({
    super.key,
    required this.selectedTimeSlots,
    required this.onTimeSelected,
    required this.onClearAll,
  });

  final Map<String, List<TimeSlot>> selectedTimeSlots;
  final ValueChanged<TimeSlot> onTimeSelected;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildSelectedChips(),
              ),
            ),
            TextButton.icon(
              onPressed: selectedTimeSlots.isEmpty ? null : onClearAll,
              icon: const Icon(Icons.clear_all),
              label: const Text('ล้างเวลา'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ScheduleGrid(
            mode: ScheduleGridMode.filter,
            selectedTimeSlots: selectedTimeSlots,
            onTimeSelected: onTimeSelected,
            readOnly: false,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectedChips() {
    if (selectedTimeSlots.isEmpty) {
      return const [Text('ยังไม่เลือกเวลา')];
    }
    final chips = <Widget>[];
    selectedTimeSlots.forEach((day, slots) {
      for (final slot in slots) {
        chips.add(
          Chip(
            label: Text(
              '${AppConstants.displayDayNames[day] ?? day} ${slot.startTime}-${slot.endTime}',
            ),
          ),
        );
      }
    });
    return chips;
  }
}
