import 'dart:math';

import 'package:flutter/material.dart';

import '../models/schedule_model.dart';
import '../utils/app_constants.dart';

enum ScheduleGridMode { edit, filter }

typedef BlockCreateCallback = void Function(TimeSlot slot, String type);
typedef BlockActionCallback = void Function(String day, ScheduleBlock block);
typedef TimeSelectionCallback = void Function(TimeSlot slot);

class ScheduleGrid extends StatefulWidget {
  const ScheduleGrid({
    super.key,
    required this.mode,
    this.schedule,
    this.selectedTimeSlots,
    this.onBlockCreated,
    this.onBlockUpdated,
    this.onBlockDeleted,
    this.onTimeSelected,
    this.onTimeSelectionPreview,
    this.readOnly = false,
    this.hourWidth = 120,
    this.rowHeight = 68,
    this.backgroundColor = AppConstants.gridBackground,
    this.majorLineColor = AppConstants.gridLineMain,
    this.minorLineColor = AppConstants.gridLineSub,
    this.scrollController,
    this.viewportKey,
    this.startHour = AppConstants.scheduleStartHour,
    this.endHour = AppConstants.scheduleEndHour,
    this.enableTouchPanSelection = true,
    this.interactiveEndHour,
  })  : assert(endHour > startHour),
        assert(interactiveEndHour == null || interactiveEndHour >= startHour),
        assert(interactiveEndHour == null || interactiveEndHour <= endHour);

  final ScheduleGridMode mode;
  final Map<String, List<ScheduleBlock>>? schedule;
  final Map<String, List<TimeSlot>>? selectedTimeSlots;
  final BlockCreateCallback? onBlockCreated;
  final BlockActionCallback? onBlockUpdated;
  final BlockActionCallback? onBlockDeleted;
  final TimeSelectionCallback? onTimeSelected;
  final TimeSelectionCallback? onTimeSelectionPreview;
  final bool readOnly;
  final double hourWidth;
  final double rowHeight;
  final Color backgroundColor;
  final Color majorLineColor;
  final Color minorLineColor;
  final ScrollController? scrollController;
  final GlobalKey? viewportKey;
  final int startHour;
  final int endHour;
  final bool enableTouchPanSelection;
  final int? interactiveEndHour;

  @override
  State<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends State<ScheduleGrid> {
  TimeSlot? _dragPreview;
  TimeSlot? _dragStartSlot;
  TimeSlot? _pendingSelection;
  Rect? _pendingSelectionRect;
  Rect? _typeSelectorRect;
  bool _pendingSelectorAlignToStart = false;
  double _currentRowHeight = 0;
  double _currentColumnWidth = 0;
  double _currentHourWidth = 0;
  double _currentGridWidth = 0;
  double _currentGridHeight = 0;
  int _maxSelectableIntervals = 1;
  int _interactiveEndHourValue = 0;
  bool _isSelecting = false;
  bool _isPanScrolling = false;
  int? _selectionDayIndex;
  double? _selectionStartIntervalValue;
  Offset? _startLocalOffset;
  Offset? _currentLocalOffset;
  Rect? _highlightRect;

  @override
  void initState() {
    super.initState();
    _interactiveEndHourValue =
        widget.interactiveEndHour != null ? min(widget.interactiveEndHour!, widget.endHour) : widget.endHour;
  }

  @override
  void didUpdateWidget(covariant ScheduleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _interactiveEndHourValue =
        widget.interactiveEndHour != null ? min(widget.interactiveEndHour!, widget.endHour) : widget.endHour;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int scheduleStart = widget.startHour;
        final int scheduleEnd = widget.endHour;
        final int rawHours = scheduleEnd - scheduleStart;
        final int totalHours = rawHours > 0 ? rawHours : 1;
        final double minGridWidth = widget.hourWidth * totalHours;
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : minGridWidth;
        final gridWidth = max(availableWidth, minGridWidth);
        final rowHeight = widget.rowHeight;
        final totalRowsHeight = rowHeight * AppConstants.scheduleDaysEn.length;
        final int intervalMinutes =
            AppConstants.scheduleIntervalMinutes > 0 ? AppConstants.scheduleIntervalMinutes : 30;
        final int totalMinutes = totalHours * 60;
        int computedIntervals = (totalMinutes / intervalMinutes).ceil();
        if (computedIntervals < 1) {
          computedIntervals = 1;
        }
        final int totalIntervals = computedIntervals;
        final columnWidth = gridWidth / totalIntervals;
        final int safeInterval = intervalMinutes > 0 ? intervalMinutes : 30;
        final int intervalsPerHour = max(1, (60 / safeInterval).round());
        final int effectiveIntervalsPerHour = min(totalIntervals, intervalsPerHour);

        final int resolvedInteractiveEndHour = widget.interactiveEndHour != null
            ? min(widget.interactiveEndHour!, widget.endHour)
            : widget.endHour;
        final int interactiveMinutes = max(0, (resolvedInteractiveEndHour - widget.startHour) * 60);
        int selectableIntervals = intervalMinutes > 0
            ? (interactiveMinutes / intervalMinutes).ceil()
            : totalIntervals;
        if (selectableIntervals < 1) {
          selectableIntervals = 1;
        }
        final int maxSelectableIntervals = min(totalIntervals, selectableIntervals);

        _currentRowHeight = rowHeight;
        _currentColumnWidth = columnWidth;
        _currentHourWidth = columnWidth * effectiveIntervalsPerHour;
        _currentGridWidth = gridWidth;
        _currentGridHeight = totalRowsHeight;
        _maxSelectableIntervals = maxSelectableIntervals;
        _interactiveEndHourValue = resolvedInteractiveEndHour;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (_pendingSelection != null) {
              final Rect? selectorRect = _typeSelectorRect;
              if (selectorRect != null &&
                  selectorRect.contains(details.localPosition)) {
                return;
              }
              _clearPendingSelection();
            }
          },
          onLongPressStart: widget.readOnly
              ? null
              : (details) {
                  _isPanScrolling = false;
                  setState(() {
                    _isSelecting = true;
                    _startLocalOffset = details.localPosition;
                    _currentLocalOffset = details.localPosition;
                  });
                  _beginSelection(
                    details.localPosition,
                    rowHeight,
                  );
                },
          onLongPressMoveUpdate: widget.readOnly
              ? null
              : (details) {
                  if (!_isSelecting) {
                    return;
                  }
                  _autoScrollDuringSelection(details);
                  final Offset? recalculated = _globalToLocal(details.globalPosition);
                  final Offset effectiveLocal =
                      recalculated ?? details.localPosition;
                  _currentLocalOffset = effectiveLocal;
                  _updateSelection(
                    effectiveLocal,
                    rowHeight,
                  );
                },
          onLongPressEnd: widget.readOnly
              ? null
              : (_) {
                  if (!_isSelecting) {
                    return;
                  }
                  setState(() {
                    _isSelecting = false;
                    _highlightRect = null;
                    _startLocalOffset = null;
                    _currentLocalOffset = null;
                  });
                  _isPanScrolling = false;
                  _selectionDayIndex = null;
                  _selectionStartIntervalValue = null;
                  _completeSelection();
                },
          onLongPressCancel: widget.readOnly
              ? null
              : _resetSelection,
          onTapUp: widget.mode == ScheduleGridMode.filter
              ? (details) =>
                  _handleTap(details.localPosition, rowHeight, columnWidth)
              : null,
          onPanStart: (details) {
            if (_isSelecting) {
              return;
            }
            final controller = widget.scrollController;
            if (controller == null || !controller.hasClients) {
              return;
            }
            _isPanScrolling = true;
          },
          onPanUpdate: (details) {
            if (_isSelecting || !_isPanScrolling) {
              return;
            }
            final controller = widget.scrollController;
            if (controller == null || !controller.hasClients) {
              return;
            }
            final double target = _clampScrollOffset(
              controller,
              controller.offset - details.delta.dx,
            );
            if ((target - controller.offset).abs() > 0.01) {
              controller.jumpTo(target);
            }
          },
          onPanEnd: (_) {
            _isPanScrolling = false;
          },
          onPanCancel: () {
            _isPanScrolling = false;
          },
          child: SizedBox(
            width: gridWidth,
            height: totalRowsHeight,
            child: Stack(
              children: [
                _buildGridBackground(
                  rowHeight,
                  columnWidth,
                  totalIntervals,
                ),
                if (widget.mode == ScheduleGridMode.edit)
                  ..._buildScheduleBlocks(rowHeight, columnWidth),
                if (widget.mode == ScheduleGridMode.filter)
                  ..._buildSelectedHighlights(rowHeight, columnWidth),
                if (_highlightRect != null)
                  Positioned(
                    left: _highlightRect!.left,
                    top: _highlightRect!.top,
                    width: _highlightRect!.width,
                    height: _highlightRect!.height,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        color: Colors.grey.withOpacity(0.28),
                      ),
                    ),
                  ),
                if (_dragPreview != null) _buildPreview(rowHeight, columnWidth),
                if (_pendingSelection != null && _pendingSelectionRect != null)
                  _buildTypeSelector(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridBackground(
    double rowHeight,
    double columnWidth,
    int totalIntervals,
  ) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _ScheduleGridPainter(
          rowHeight: rowHeight,
          columnWidth: columnWidth,
          totalIntervals: totalIntervals,
          backgroundColor: widget.backgroundColor,
          majorLineColor: widget.majorLineColor,
          minorLineColor: widget.minorLineColor,
        ),
      ),
    );
  }

  List<Widget> _buildScheduleBlocks(double rowHeight, double columnWidth) {
    final blocks = <Widget>[];
    final schedule = widget.schedule ?? <String, List<ScheduleBlock>>{};
    for (final day in AppConstants.scheduleDaysEn) {
      final dayBlocks = schedule[day] ?? <ScheduleBlock>[];
      for (final block in dayBlocks) {
        blocks.add(_buildBlock(day, block, rowHeight, columnWidth));
      }
    }
    return blocks;
  }

  Widget _buildBlock(
    String day,
    ScheduleBlock block,
    double rowHeight,
    double columnWidth,
  ) {
    final position = _calculateBlockRect(day, block.startTime, block.endTime, rowHeight, columnWidth);
    final isTeaching = block.type == 'teaching';
    final color = isTeaching ? AppConstants.teachingBlockBg : AppConstants.busyBlockBg;
    final border =
        isTeaching ? AppConstants.teachingBlockBorder : AppConstants.busyBlockBorder;

    return Positioned(
      left: position.left,
      top: position.top,
      width: position.width,
      height: position.height,
      child: GestureDetector(
        onTap: widget.readOnly
            ? null
            : () => widget.onBlockUpdated?.call(day, block),
        onLongPress: widget.readOnly
            ? null
            : () => widget.onBlockDeleted?.call(day, block),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildBlockLabel(block, isTeaching),
        ),
      ),
    );
  }

  Widget _buildBlockLabel(ScheduleBlock block, bool isTeaching) {
    if (block.note?.isNotEmpty == true) {
      return Text(
        block.note!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (isTeaching) {
      return const Text(
        'สอน',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> _buildSelectedHighlights(double rowHeight, double columnWidth) {
    final highlights = <Widget>[];
    final selected = widget.selectedTimeSlots ?? <String, List<TimeSlot>>{};
    for (final entry in selected.entries) {
      for (final slot in entry.value) {
        final rect =
            _calculateBlockRect(entry.key, slot.startTime, slot.endTime, rowHeight, columnWidth);
        highlights.add(
          Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: Container(
              decoration: BoxDecoration(
                color: AppConstants.highlightBg
                    .withAlpha((0.7 * 255).round()),
                border: Border.all(color: AppConstants.highlightBorder, width: 1.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      }
    }
    return highlights;
  }

  Widget _buildPreview(double rowHeight, double columnWidth) {
    final preview = _dragPreview!;
    final rect = _calculateBlockRect(
      preview.day,
      preview.startTime,
      preview.endTime,
      rowHeight,
      columnWidth,
    );
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: AppConstants.highlightBg
                .withAlpha((0.5 * 255).round()),
            border: Border.all(color: AppConstants.highlightBorder, width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  void _beginSelection(
    Offset localPosition,
    double rowHeight,
  ) {
    final _SelectionInfo? info = _resolveSelectionInfo(localPosition, rowHeight);
    if (info == null) {
      return;
    }
    _clearPendingSelection();
    final int maxIntervals = max(1, _maxSelectableIntervals);
    int startIntervalIndex = info.intervalValue.floor();
    startIntervalIndex = max(0, min(startIntervalIndex, maxIntervals - 1));
    int endIntervalIndex = startIntervalIndex + 1;
    endIntervalIndex = min(maxIntervals, max(endIntervalIndex, startIntervalIndex + 1));
    if (endIntervalIndex <= startIntervalIndex) {
      endIntervalIndex = min(maxIntervals, startIntervalIndex + 1);
    }
    final TimeSlot initialSlot = _slotForIntervalRange(
      info.dayIndex,
      startIntervalIndex,
      endIntervalIndex,
    );
    _selectionDayIndex = info.dayIndex;
    _selectionStartIntervalValue = info.intervalValue;
    _dragStartSlot = initialSlot;
    _dragPreview = initialSlot;
    final Rect? initialRect = _rectForSlot(initialSlot);
    if (initialRect != null) {
      setState(() {
        _highlightRect = initialRect;
        _startLocalOffset = initialRect.topLeft;
        _currentLocalOffset = initialRect.bottomRight;
      });
    }
    widget.onTimeSelectionPreview?.call(initialSlot);
  }

  void _updateSelection(
    Offset localPosition,
    double rowHeight,
  ) {
    if (_dragStartSlot == null ||
        _selectionDayIndex == null ||
        _selectionStartIntervalValue == null) {
      return;
    }
    final _SelectionInfo? info =
        _resolveSelectionInfo(localPosition, rowHeight, fallbackDayIndex: _selectionDayIndex);
    if (info == null) {
      return;
    }

    final double startValue = _selectionStartIntervalValue!;
    final double pointerValue = info.intervalValue;
    double from = min(startValue, pointerValue);
    double to = max(startValue, pointerValue);
    if ((to - from) < 1.0) {
      if (pointerValue >= startValue) {
        to = startValue + 1.0;
      } else {
        from = startValue - 1.0;
      }
    }

    final double maxIntervalsDouble = max(1, _maxSelectableIntervals).toDouble();
    from = from.clamp(0.0, maxIntervalsDouble - 1.0);
    to = to.clamp(1.0, maxIntervalsDouble);

    final int maxIntervalIndex = max(0, maxIntervalsDouble.toInt() - 1);
    int startIntervalIndex = from.floor();
    startIntervalIndex = max(0, min(startIntervalIndex, maxIntervalIndex));
    final int absoluteMaxEnd = maxIntervalsDouble.toInt();
    int endIntervalIndex = max(startIntervalIndex + 1, to.ceil());
    endIntervalIndex = max(startIntervalIndex + 1, min(endIntervalIndex, absoluteMaxEnd));
    if (endIntervalIndex > absoluteMaxEnd) {
      endIntervalIndex = absoluteMaxEnd;
    }
    if (startIntervalIndex >= endIntervalIndex) {
      startIntervalIndex = max(0, endIntervalIndex - 1);
    }

    final TimeSlot slot = _slotForIntervalRange(
      _selectionDayIndex!,
      startIntervalIndex,
      endIntervalIndex,
    );
    final Rect? rect = _rectForSlot(slot);
    _dragPreview = slot;
    if (rect != null && rect != _highlightRect) {
      setState(() {
        _highlightRect = rect;
        _startLocalOffset = rect.topLeft;
        _currentLocalOffset = rect.bottomRight;
      });
    } else if (rect == null && _startLocalOffset != null && _currentLocalOffset != null) {
      setState(() {
        _highlightRect = Rect.fromPoints(_startLocalOffset!, _currentLocalOffset!);
      });
    }
    widget.onTimeSelectionPreview?.call(slot);
  }

  void _handleTap(Offset position, double rowHeight, double columnWidth) {
    if (widget.mode != ScheduleGridMode.filter) return;
    final slot = _offsetToSlot(position, rowHeight, columnWidth);
    if (slot == null) return;
    widget.onTimeSelected?.call(slot.normalized());
    setState(() {
      _dragPreview = null;
      _dragStartSlot = null;
    });
  }

  void _completeSelection() {
    if (_dragPreview == null) {
      setState(() => _dragStartSlot = null);
      return;
    }
    final TimeSlot snapped = _snapSlotToIntervals(_dragPreview!);
    final preview = snapped.normalized();
    if (widget.mode == ScheduleGridMode.edit) {
      final bool alignToStart =
          _dragStartSlot != null && snapped.startTime != _dragStartSlot!.startTime;
      setState(() {
        _pendingSelection = preview;
        _pendingSelectionRect = _rectForSlot(preview);
        _dragPreview = preview;
        _pendingSelectorAlignToStart = alignToStart;
      });
    } else {
      widget.onTimeSelected?.call(preview);
      setState(() {
        _dragPreview = null;
      });
    }
    _dragStartSlot = null;
  }

  void _resetSelection() {
    setState(() {
      _dragPreview = null;
      _dragStartSlot = null;
      _pendingSelection = null;
      _pendingSelectionRect = null;
      _typeSelectorRect = null;
      _pendingSelectorAlignToStart = false;
      _isSelecting = false;
      _isPanScrolling = false;
      _selectionDayIndex = null;
      _selectionStartIntervalValue = null;
      _highlightRect = null;
      _startLocalOffset = null;
      _currentLocalOffset = null;
    });
  }

  Offset? _globalToLocal(Offset globalPosition) {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return renderObject.globalToLocal(globalPosition);
    }
    return null;
  }

  double _clampScrollOffset(ScrollController controller, double proposed) {
    final double minExtent = controller.position.minScrollExtent;
    final double maxExtent = controller.position.maxScrollExtent;
    final double hourWidth = _currentHourWidth > 0 ? _currentHourWidth : widget.hourWidth;
    final double interactiveMax = max(0, (_interactiveEndHourValue - widget.startHour) * hourWidth);
    final double cappedMax = max(minExtent, min(maxExtent, interactiveMax));
    return proposed.clamp(minExtent, cappedMax);
  }

  bool _autoScrollDuringSelection(LongPressMoveUpdateDetails details) {
    final ScrollController? controller = widget.scrollController;
    if (controller == null || !controller.hasClients) {
      return false;
    }
    final RenderBox? viewportBox =
        widget.viewportKey?.currentContext?.findRenderObject() as RenderBox? ??
            context.findRenderObject() as RenderBox?;
    if (viewportBox == null) {
      return false;
    }
    const double edgeThreshold = 40.0;
    final Offset localOffset = viewportBox.globalToLocal(details.globalPosition);
    final double viewportWidth = viewportBox.size.width;
    if (viewportWidth <= 0) {
      return false;
    }
    final double hourWidth = _currentHourWidth > 0 ? _currentHourWidth : widget.hourWidth;
    if (hourWidth <= 0) {
      return false;
    }

    double? targetOffset;
    if (localOffset.dx < edgeThreshold) {
      targetOffset = controller.offset - hourWidth;
    } else if (localOffset.dx > viewportWidth - edgeThreshold) {
      targetOffset = controller.offset + hourWidth;
    }

    if (targetOffset == null) {
      return false;
    }

    final double clampedTarget = _clampScrollOffset(controller, targetOffset);

    if ((clampedTarget - controller.offset).abs() < 0.5) {
      return false;
    }

    controller.animateTo(
      clampedTarget,
      duration: const Duration(milliseconds: 90),
      curve: Curves.linear,
    );
    return true;
  }

  _BlockRect _calculateBlockRect(
    String day,
    String startTime,
    String endTime,
    double rowHeight,
    double columnWidth,
  ) {
    final dayIndex = AppConstants.scheduleDaysEn.indexOf(day);
    final startMinutes = _timeToMinutes(startTime);
    final endMinutes = _timeToMinutes(endTime);
    final startIndex =
        ((startMinutes - widget.startHour * 60) / AppConstants.scheduleIntervalMinutes)
            .clamp(0, double.infinity);
    final endIndex =
        ((endMinutes - widget.startHour * 60) / AppConstants.scheduleIntervalMinutes)
            .clamp(0, double.infinity);
    final left = startIndex * columnWidth;
    final width = max((endIndex - startIndex) * columnWidth, columnWidth);
    final top = dayIndex * rowHeight;
    return _BlockRect(left: left, top: top, width: width, height: max(rowHeight - 2, 0));
  }

  Rect? _rectForSlot(TimeSlot slot) {
    final rect = _calculateBlockRect(
      slot.day,
      slot.startTime,
      slot.endTime,
      _currentRowHeight,
      _currentColumnWidth,
    );
    return Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height);
  }

  TimeSlot _slotForIntervalRange(int dayIndex, int startInterval, int endInterval) {
    final List<String> days = AppConstants.scheduleDaysEn;
    if (days.isEmpty) {
      return TimeSlot(day: '', startTime: '00:00', endTime: '00:00');
    }
    final int safeDayIndex = max(0, min(dayIndex, days.length - 1));
    final int maxIntervals = max(1, _maxSelectableIntervals);
    int safeStart = max(0, min(startInterval, maxIntervals - 1));
    int safeEnd = max(safeStart + 1, min(endInterval, maxIntervals));
    if (safeEnd <= safeStart) {
      safeEnd = min(maxIntervals, safeStart + 1);
    }
    final int intervalMinutes = AppConstants.scheduleIntervalMinutes;
    final int minMinutes = widget.startHour * 60;
    final int startMinutes = minMinutes + safeStart * intervalMinutes;
    final int endMinutes = minMinutes + safeEnd * intervalMinutes;
    return TimeSlot(
      day: days[safeDayIndex],
      startTime: _minutesToTimeString(startMinutes),
      endTime: _minutesToTimeString(endMinutes),
    );
  }

  TimeSlot? _offsetToSlot(
    Offset offset,
    double rowHeight,
    double columnWidth, {
    String? fallbackDay,
  }) {
    double dy = offset.dy;
    double dx = offset.dx;
    final fallbackIndex =
        fallbackDay != null ? AppConstants.scheduleDaysEn.indexOf(fallbackDay) : -1;
    if (dy.isNaN || dy.isInfinite) {
      dy = fallbackIndex >= 0 ? fallbackIndex * rowHeight : 0;
    }
    if (dx.isNaN || dx.isInfinite) {
      dx = 0;
    }
    int rowIndex = dy ~/ rowHeight;
    final int lastRow = AppConstants.scheduleDaysEn.length - 1;
    if (lastRow < 0) {
      return null;
    }
    if (rowIndex < 0 || rowIndex > lastRow) {
      if (fallbackIndex >= 0) {
        rowIndex = fallbackIndex;
        if (rowIndex < 0) {
          return null;
        }
      } else {
        return null;
      }
    }
    final day = AppConstants.scheduleDaysEn[rowIndex];

    final double maxDx = max(0, _maxSelectableIntervals * columnWidth - 0.0001);
    final double clampedDx = dx.clamp(0.0, maxDx);
    final rawIndex = (clampedDx / columnWidth).floor();
    final int maxIndex = max(0, _maxSelectableIntervals - 1);
    final intervalIndex = max(min(rawIndex, maxIndex), 0);
    final minutesOffset = intervalIndex * AppConstants.scheduleIntervalMinutes;
    final startMinutes = widget.startHour * 60 + minutesOffset;
    final startTime = _minutesToTimeString(startMinutes);
    final endTime = _minutesToTimeString(startMinutes + AppConstants.scheduleIntervalMinutes);

    return TimeSlot(day: day, startTime: startTime, endTime: endTime);
  }

  _SelectionInfo? _resolveSelectionInfo(
    Offset position,
    double rowHeight, {
    int? fallbackDayIndex,
  }) {
    if (rowHeight <= 0) {
      return null;
    }
    double dy = position.dy;
    if (dy.isNaN || dy.isInfinite) {
      dy = 0;
    }
    int rowIndex = dy ~/ rowHeight;
    final int lastRow = AppConstants.scheduleDaysEn.length - 1;
    if (rowIndex < 0 || rowIndex > lastRow) {
      if (fallbackDayIndex != null) {
        rowIndex = max(0, min(fallbackDayIndex, lastRow));
      } else {
        return null;
      }
    }

    final double intervalWidth =
        _currentColumnWidth > 0 ? _currentColumnWidth : widget.hourWidth / 2;
    final double totalIntervals = max(1, _maxSelectableIntervals).toDouble();
    if (intervalWidth <= 0 || totalIntervals <= 0) {
      return null;
    }

    double dx = position.dx;
    if (dx.isNaN || dx.isInfinite) {
      dx = 0;
    }
    final double maxDx = max(0.0, totalIntervals * intervalWidth - 0.0001);
    final double clampedDx = dx.clamp(0.0, maxDx);
    final double intervalValue = intervalWidth == 0 ? 0 : clampedDx / intervalWidth;

    return _SelectionInfo(dayIndex: rowIndex, intervalValue: intervalValue);
  }

  TimeSlot _snapSlotToIntervals(TimeSlot slot) {
    int dayIndex = AppConstants.scheduleDaysEn.indexOf(slot.day);
    dayIndex = max(0, min(dayIndex, AppConstants.scheduleDaysEn.length - 1));
    final int intervalMinutes = AppConstants.scheduleIntervalMinutes;
    final int minMinutes = widget.startHour * 60;
    final int maxMinutes = _interactiveEndHourValue * 60;
    final int requestedStart = _timeToMinutes(slot.startTime);
    final int requestedEnd = _timeToMinutes(slot.endTime);
    final int rawStart = max(min(requestedStart, maxMinutes - intervalMinutes), minMinutes);
    final int rawEnd = max(min(requestedEnd, maxMinutes), rawStart + intervalMinutes);
    int startInterval = ((rawStart - minMinutes) / intervalMinutes).floor();
    int endInterval = ((rawEnd - minMinutes) / intervalMinutes).ceil();
    final int maxIntervals = max(1, _maxSelectableIntervals);
    startInterval = max(0, min(startInterval, maxIntervals - 1));
    endInterval = max(startInterval + 1, min(endInterval, maxIntervals));
    return _slotForIntervalRange(dayIndex, startInterval, endInterval);
  }

  int _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return widget.startHour * 60;
    final hour = int.tryParse(parts[0]) ?? widget.startHour;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  String _minutesToTimeString(int minutes) {
    final clamped = minutes.clamp(
      widget.startHour * 60,
      _interactiveEndHourValue * 60,
    );
    final hour = clamped ~/ 60;
    final minute = clamped % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void _clearPendingSelection() {
    if (_pendingSelection == null && _dragPreview == null) return;
    setState(() {
      _pendingSelection = null;
      _pendingSelectionRect = null;
      _dragPreview = null;
      _typeSelectorRect = null;
      _pendingSelectorAlignToStart = false;
      _highlightRect = null;
      _startLocalOffset = null;
      _currentLocalOffset = null;
    });
  }

  Widget _buildTypeSelector() {
    final slot = _pendingSelection!;
    final rect = _pendingSelectionRect!;
    const double cardWidth = 150;
    const double cardHeight = 96;
    const double horizontalMargin = 8;
    final double desiredLeft = _pendingSelectorAlignToStart ? rect.left : rect.right - cardWidth;
    final double left = desiredLeft.clamp(
      horizontalMargin,
      max(horizontalMargin, _currentGridWidth - cardWidth - horizontalMargin),
    );
    final double top = (rect.top + (rect.height - cardHeight) / 2)
        .clamp(8, max(8.0, _currentGridHeight - cardHeight - 8));
    _typeSelectorRect = Rect.fromLTWH(left, top, cardWidth, cardHeight);

    return Positioned(
      left: left,
      top: top,
      width: cardWidth,
      height: cardHeight,
      child: Material(
        color: Colors.white,
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TypeOptionButton(
              label: 'สอน',
              background: AppConstants.teachingBlockBg,
              textColor: Colors.black87,
              onTap: () => _handleTypeSelection(slot, 'teaching'),
            ),
            const SizedBox(height: 8),
            _TypeOptionButton(
              label: 'ไม่ว่าง',
              background: AppConstants.busyBlockBg,
              textColor: Colors.black87,
              onTap: () => _handleTypeSelection(slot, 'busy'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTypeSelection(TimeSlot slot, String type) {
    widget.onBlockCreated?.call(slot.normalized(), type);
    setState(() {
      _pendingSelection = null;
      _pendingSelectionRect = null;
      _dragPreview = null;
      _typeSelectorRect = null;
    });
  }
}

class _ScheduleGridPainter extends CustomPainter {
  _ScheduleGridPainter({
    required this.rowHeight,
    required this.columnWidth,
    required this.totalIntervals,
    required this.backgroundColor,
    required this.majorLineColor,
    required this.minorLineColor,
  });

  final double rowHeight;
  final double columnWidth;
  final int totalIntervals;
  final Color backgroundColor;
  final Color majorLineColor;
  final Color minorLineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final majorPaint = Paint()
      ..color = majorLineColor
      ..strokeWidth = 1.4;
    final minorPaint = Paint()
      ..color = minorLineColor
      ..strokeWidth = 1.0;

    // Horizontal lines (days)
    for (var i = 0; i <= AppConstants.scheduleDaysEn.length; i++) {
      final dy = i * rowHeight;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), majorPaint);
    }

    // Vertical lines (time)
    final intervalMinutes = AppConstants.scheduleIntervalMinutes;
    final safeInterval = intervalMinutes <= 0 ? 30 : intervalMinutes;
    final computedIntervals = (60 / safeInterval).round();
    final intervalsPerHour = computedIntervals < 1 ? 1 : computedIntervals;
    for (var i = 0; i <= totalIntervals; i++) {
      final dx = i * columnWidth;
      final paint = i % intervalsPerHour == 0 ? majorPaint : minorPaint;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScheduleGridPainter oldDelegate) {
    return oldDelegate.rowHeight != rowHeight ||
        oldDelegate.columnWidth != columnWidth ||
        oldDelegate.totalIntervals != totalIntervals ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.majorLineColor != majorLineColor ||
        oldDelegate.minorLineColor != minorLineColor;
  }
}

class _BlockRect {
  const _BlockRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class _SelectionInfo {
  const _SelectionInfo({
    required this.dayIndex,
    required this.intervalValue,
  });

  final int dayIndex;
  final double intervalValue;
}

class _TypeOptionButton extends StatelessWidget {
  const _TypeOptionButton({
    required this.label,
    required this.background,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withAlpha((0.05 * 255).round()),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
