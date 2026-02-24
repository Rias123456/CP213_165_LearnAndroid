import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../services/filter_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../widgets/colon_aligned_hour_header.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _ScheduleSelection {
  const _ScheduleSelection({
    required this.dayIndex,
    required this.startSlot,
    required this.endSlot,
  }) : assert(endSlot >= startSlot);

  final int dayIndex;
  final int startSlot;
  final int endSlot;

  int get durationSlots => math.max(0, endSlot - startSlot);
}

class _ScheduleGridPainter extends CustomPainter {
  const _ScheduleGridPainter({
    required this.hourWidth,
    required this.totalHours,
    required this.slotsPerHour,
  });

  final double hourWidth;
  final int totalHours;
  final int slotsPerHour;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = AppConstants.scheduleGridBackground;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final Paint mainPaint = Paint()
      ..color = AppConstants.gridLineMain
      ..strokeWidth = 1;
    final Paint divisionPaint = Paint()
      ..color = AppConstants.gridLineSub
      ..strokeWidth = 1;
    final Paint borderPaint = Paint()
      ..color = AppConstants.scheduleGridBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int hour = 0; hour <= totalHours; hour++) {
      final double x = hour * hourWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), mainPaint);
      if (hour < totalHours && slotsPerHour > 1) {
        for (int slot = 1; slot < slotsPerHour; slot++) {
          final double slotX = x + hourWidth * slot / slotsPerHour;
          canvas.drawLine(Offset(slotX, 0), Offset(slotX, size.height), divisionPaint);
        }
      }
    }
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), mainPaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), mainPaint);
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScheduleGridPainter oldDelegate) {
    return oldDelegate.hourWidth != hourWidth ||
        oldDelegate.totalHours != totalHours ||
        oldDelegate.slotsPerHour != slotsPerHour;
  }
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _storageService = StorageService();
  final _filterService = FilterService();

  List<Map<String, dynamic>> _allTutors = [];
  List<Map<String, dynamic>> _filteredTutors = [];
  final Set<String> _selectedSubjectLabels = <String>{};
  bool _loading = true;
  final ScrollController _timelineScrollController = ScrollController();
  final GlobalKey _timelineViewportKey = GlobalKey();
  final List<_ScheduleSelection> _selectedRanges = <_ScheduleSelection>[];
  _ScheduleSelection? _activeSelection;
  int? _draggingDayIndex;
  int? _dragAnchorSlot;
  final List<GlobalKey> _dayGridKeys =
      List<GlobalKey>.generate(AppConstants.scheduleDaysTh.length, (_) => GlobalKey());

  static const double _scheduleHourWidth = 100;
  static const double _scheduleRowHeight = 60;
  static const double _dayLabelWidth = 92;
  static const int _adminScheduleCutoffHour = 21;

  Offset? _lastPointerGlobal;
  DateTime _lastSnap = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _snapInterval = Duration(milliseconds: 240);
  VoidCallback? _snapScrollListener;
  bool _snapListenerAttached = false;

  int get _slotsPerHour => math.max(1, 60 ~/ AppConstants.scheduleIntervalMinutes);

  int get _scheduleEndHour =>
      math.min(_adminScheduleCutoffHour, AppConstants.scheduleEndHour);

  int get _displayedHourCount => math.max(
      0, (_scheduleEndHour - AppConstants.scheduleStartHour) - 1);

  int get _totalSlots => _displayedHourCount * _slotsPerHour;

  int get _maxSelectableSlots {
    final int interactiveEndHour =
        math.min(AppConstants.scheduleInteractiveEndHour, _scheduleEndHour);
    final int interactiveHours = interactiveEndHour - AppConstants.scheduleStartHour;
    if (interactiveHours <= 0) {
      return math.max(1, _slotsPerHour);
    }
    final int selectableSlots = interactiveHours * _slotsPerHour;
    return math.max(1, math.min(_totalSlots, selectableSlots));
  }

  double get _slotWidth => _scheduleHourWidth / _slotsPerHour;

  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    try {
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  @override
  void dispose() {
    _detachSnapListener();
    _timelineScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTutors() async {
    setState(() => _loading = true);
    final tutors = await _storageService.getAllTutors();
    setState(() {
      _allTutors = tutors;
      _filteredTutors = tutors;
      _loading = false;
    });
  }

  Future<void> _applyFilters() async {
    setState(() => _loading = true);
    final List<String> subjectLabels = _selectedSubjectLabels
        .where((label) => label != 'ทั้งหมด')
        .toList(growable: false);
    final timeSlots = _buildSelectedTimeSlots();
    final results = await _filterService.applyFilters(
      subjectLabels: subjectLabels.isEmpty ? null : subjectLabels,
      timeSlots: timeSlots,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _filteredTutors = results;
      _loading = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSubjectLabels.clear();
      _selectedRanges.clear();
      _activeSelection = null;
      _filteredTutors = _allTutors;
    });
  }

  Map<String, List<Map<String, String>>>? _buildSelectedTimeSlots() {
    if (_selectedRanges.isEmpty) {
      return null;
    }
    final Map<String, List<Map<String, String>>> result = {};
    for (final selection in _selectedRanges) {
      if (selection.durationSlots <= 0) {
        continue;
      }
      final int safeDay =
          _clampInt(selection.dayIndex, 0, AppConstants.scheduleDaysEn.length - 1);
      final String dayKey = AppConstants.scheduleDaysEn[safeDay];
      final String startTime =
          _formatTimeOfDay(_timeForSlot(selection.startSlot));
      final String endTime = _formatTimeOfDay(_timeForSlot(selection.endSlot));
      result.putIfAbsent(dayKey, () => <Map<String, String>>[]).add({
            'startTime': startTime,
            'endTime': endTime,
          });
    }
    if (result.isEmpty) {
      return null;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.adminDashboardBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.adminDashboardBackground,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'แดชบอร์ดแอดมิน',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilters(),
                  _buildStatusBar(),
                  _buildTimeSelector(),
                  const SizedBox(height: 16),
                  _buildTutorSection(),
                ],
              ),
            ),
            if (_loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x88FFFFFF),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 255, 171, 171),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);
    final List<String> availableSubjects = _subjectLabels;
    final List<String> validSelections = _selectedSubjectLabels
        .where((label) => availableSubjects.contains(label) && label != 'ทั้งหมด')
        .toList();
    final String? dropdownValue = validSelections.isEmpty ? null : validSelections.last;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: dropdownValue,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'รายวิชา',
                    hintText: 'เลือกวิชา',
                    prefixIcon: const Icon(Icons.book, color: Color(0xFF616161)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: availableSubjects
                      .map(
                        (subject) => DropdownMenuItem<String>(
                          value: subject,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subject,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (validSelections.contains(subject))
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: availableSubjects.isEmpty
                      ? null
                      : (String? subject) {
                          if (subject == null) {
                            return;
                          }
                          setState(() {
                            if (subject == 'ทั้งหมด') {
                              _selectedSubjectLabels.clear();
                            } else if (_selectedSubjectLabels.contains(subject)) {
                              _selectedSubjectLabels.remove(subject);
                            } else {
                              _selectedSubjectLabels.add(subject);
                            }
                            _selectedSubjectLabels.removeWhere(
                              (label) =>
                                  !availableSubjects.contains(label) || label == 'ทั้งหมด',
                            );
                          });
                          _applyFilters();
                        },
                  selectedItemBuilder: (BuildContext context) {
                    return availableSubjects.map((String subject) {
                      final bool hasSelection = validSelections.isNotEmpty;
                      final String displayText = hasSelection
                          ? 'เลือกแล้ว ${validSelections.length} วิชา'
                          : 'เลือกวิชา';
                      return Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          displayText,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              const SizedBox(width: 16),
              _buildLogoutButton(),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: validSelections.isEmpty
                  ? null
                  : () {
                      setState(() => _selectedSubjectLabels.clear());
                      _applyFilters();
                    },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('ล้างวิชา'),
            ),
          ),
          if (validSelections.isEmpty)
            Text(
              'เลือกได้หลายวิชาเพื่อกรองรายชื่อครู',
              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF757575)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: validSelections
                  .map(
                    (subject) => InputChip(
                      label: Text(subject),
                      onDeleted: () {
                        setState(() => _selectedSubjectLabels.remove(subject));
                        _applyFilters();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.logoutGradient1, AppConstants.logoutGradient2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FF6B6B),
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _confirmLogout,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('ออกจากระบบ',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final bool hasSubjectFilter = _selectedSubjectLabels.isNotEmpty;
    final bool hasTimeFilter = _selectedRanges.isNotEmpty;
    if (!hasSubjectFilter && !hasTimeFilter) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_alt_outlined,
                size: 20, color: AppConstants.darkPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _statusMessage(),
                style: const TextStyle(
                  color: AppConstants.darkPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('ล้างทั้งหมด'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.scheduleGridHeaderBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ตารางสอน',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (_selectedRanges.isNotEmpty || _activeSelection != null)
                TextButton.icon(
                  onPressed: _clearTimeSelection,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('ล้างเวลา'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScheduleGrid(),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final List<String> savedSelections = _selectedRanges
                  .map((selection) => '• ${_formatSelection(selection)}')
                  .toList(growable: false);
              final _ScheduleSelection? active = _activeSelection;
              if (active != null && active.durationSlots > 0) {
                savedSelections
                    .add('• กำลังเลือก: ${_formatSelection(active)}');
              }
              final String text = savedSelections.isEmpty
                  ? 'แตะหรือกดค้างแล้วลากในตารางเพื่อเลือกช่วงเวลาที่ต้องการกรอง'
                  : 'ช่วงเวลาที่เลือก:\n${savedSelections.join('\n')}';
              return Text(
                text,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: const Color(0xFF757575)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleGrid() {
    final theme = Theme.of(context);
    final int totalHours =
        math.max(0, _scheduleEndHour - AppConstants.scheduleStartHour);
    final int displayedHours = math.max(0, totalHours - 1);
    final double gridWidth = _totalSlots * _slotWidth;
    final List<int> hourLabels = List<int>.generate(
      displayedHours + 1,
      (int index) => AppConstants.scheduleStartHour + index,
    );
    final BorderRadius gridRadius = BorderRadius.circular(16);
    final List<List<int>> tutorCounts = _calculateTutorCounts();
    final TextStyle countTextStyle =
        (theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
      color: const Color(0xFFD32F2F),
      fontWeight: FontWeight.w700,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.scheduleGridBackground,
        borderRadius: gridRadius,
      ),
      child: ClipRRect(
        borderRadius: gridRadius,
        child: ClipRect(
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (!_timelineScrollController.hasClients) {
                return;
              }
              final double delta = -details.delta.dx;
              final double minOffset = _timelineScrollController.position.minScrollExtent;
              final double maxOffset = _timelineScrollController.position.maxScrollExtent;
              final double nextOffset =
                  (_timelineScrollController.offset + delta).clamp(minOffset, maxOffset);
              _timelineScrollController.jumpTo(nextOffset);
            },
            child: SingleChildScrollView(
              key: _timelineViewportKey,
              controller: _timelineScrollController,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: _dayLabelWidth,
                                color: Colors.white,
                              ),
                              Container(
                                width: gridWidth,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: ColonAlignedHourHeaderPainter(
                                labels: hourLabels
                                    .map((hour) => _formatHourLabel(hour))
                                    .toList(growable: false),
                                leftGutter: _dayLabelWidth,
                                slotWidth: _scheduleHourWidth,
                                textStyle: (theme.textTheme.bodySmall ??
                                        const TextStyle(fontSize: 12))
                                    .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                                bottomPadding: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: List<Widget>.generate(
                        AppConstants.scheduleDaysTh.length, (int dayIndex) {
                      return SizedBox(
                        height: _scheduleRowHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: _dayLabelWidth,
                              color: AppConstants.scheduleGridLabelBackground,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 18),
                              child: Text(
                                AppConstants.scheduleDaysTh[dayIndex],
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onLongPressStart: (details) =>
                                  _handleLongPressStart(dayIndex, details),
                              onLongPressMoveUpdate: _handleLongPressMoveUpdate,
                              onLongPressEnd: (_) => _handleLongPressEnd(),
                              child: SizedBox(
                                key: _dayGridKeys[dayIndex],
                                width: gridWidth,
                                height: _scheduleRowHeight,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _ScheduleGridPainter(
                                          hourWidth: _scheduleHourWidth,
                                          totalHours: displayedHours,
                                          slotsPerHour: _slotsPerHour,
                                        ),
                                      ),
                                    ),
                                    ..._buildSelectionHighlights(dayIndex),
                                    Positioned.fill(
                                      child: _buildTutorCountOverlay(
                                        tutorCounts[dayIndex],
                                        countTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearTimeSelection() {
    if (_selectedRanges.isEmpty && _activeSelection == null) {
      return;
    }
    setState(() {
      _selectedRanges.clear();
      _activeSelection = null;
    });
    _detachSnapListener();
    _lastPointerGlobal = null;
    _applyFilters();
  }

  void _handleLongPressStart(int dayIndex, LongPressStartDetails details) {
    final int slot = _slotFromDx(details.localPosition.dx);
    setState(() {
      _draggingDayIndex = dayIndex;
      _dragAnchorSlot = slot;
      _activeSelection = _ScheduleSelection(
        dayIndex: dayIndex,
        startSlot: slot,
        endSlot: math.min(_maxSelectableSlots, slot + 1),
      );
    });
    _lastPointerGlobal = details.globalPosition;
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_dragAnchorSlot == null) {
      return;
    }
    _lastPointerGlobal = details.globalPosition;
    int? resolvedDay =
        _resolveDayFromGlobal(details.globalPosition) ?? _draggingDayIndex;
    if (resolvedDay == null) {
      return;
    }
    int resolvedDayValue = resolvedDay;
    double? localDx = _localDxForDay(details.globalPosition, resolvedDayValue);
    if (localDx == null) {
      return;
    }
    if (_autoScrollIfNeeded(details.globalPosition)) {
      resolvedDay =
          _resolveDayFromGlobal(details.globalPosition) ?? resolvedDayValue;
      resolvedDayValue = resolvedDay ?? resolvedDayValue;
      localDx =
          _localDxForDay(details.globalPosition, resolvedDayValue);
      if (localDx == null) {
        return;
      }
    }
    final int currentSlot = _slotFromDx(localDx);
    final int anchor = _dragAnchorSlot!;
    final int start = math.min(anchor, currentSlot);
    final int end = math.max(anchor, currentSlot) + 1;
    setState(() {
      _draggingDayIndex = resolvedDayValue;
      _activeSelection = _ScheduleSelection(
        dayIndex: resolvedDayValue,
        startSlot: start,
        endSlot: math.min(_maxSelectableSlots, end),
      );
    });
  }

  void _handleLongPressEnd() {
    if (_dragAnchorSlot == null) {
      return;
    }
    final _ScheduleSelection? selection = _activeSelection;
    setState(() {
      _draggingDayIndex = null;
      _dragAnchorSlot = null;
      _activeSelection = null;
    });
    _detachSnapListener();
    _lastPointerGlobal = null;
    if (selection != null && selection.durationSlots > 0) {
      _addOrMergeSelection(selection);
    } else {
      _applyFilters();
    }
  }

  void _addOrMergeSelection(_ScheduleSelection selection) {
    final _ScheduleSelection normalized = _normalizeSelection(selection);
    if (normalized.durationSlots <= 0) {
      _applyFilters();
      return;
    }
    setState(() {
      _selectedRanges
          .removeWhere((existing) => _selectionsOverlap(existing, normalized));
      _selectedRanges.add(normalized);
      _selectedRanges.sort((a, b) {
        if (a.dayIndex != b.dayIndex) {
          return a.dayIndex.compareTo(b.dayIndex);
        }
        return a.startSlot.compareTo(b.startSlot);
      });
    });
    _applyFilters();
  }

  bool _autoScrollIfNeeded(Offset globalPosition) {
    if (!_timelineScrollController.hasClients) {
      return false;
    }
    final ScrollPosition position = _timelineScrollController.position;
    final BuildContext? viewportContext = _timelineViewportKey.currentContext;
    if (viewportContext == null) {
      return false;
    }
    final RenderBox? viewportBox =
        viewportContext.findRenderObject() as RenderBox?;
    if (viewportBox == null) {
      return false;
    }
    final double viewportWidth = viewportBox.size.width;
    if (viewportWidth <= 0) {
      return false;
    }
    const double edgeMargin = 48.0;
    final Offset localInViewport = viewportBox.globalToLocal(globalPosition);
    final double visibleDx = localInViewport.dx.clamp(0, viewportWidth);
    if (visibleDx <= edgeMargin) {
      final bool snapped = _edgeSnap(-1);
      if (!snapped) {
        _refreshSelectionForPointer();
      }
      return snapped;
    }
    if (visibleDx >= viewportWidth - edgeMargin) {
      final bool snapped = _edgeSnap(1);
      if (!snapped) {
        _refreshSelectionForPointer();
      }
      return snapped;
    }
    return false;
  }

  void _refreshSelectionForPointer() {
    if (_dragAnchorSlot == null) {
      return;
    }
    final Offset? globalPosition = _lastPointerGlobal;
    if (globalPosition == null) {
      return;
    }
    int? resolvedDay =
        _resolveDayFromGlobal(globalPosition) ?? _draggingDayIndex;
    if (resolvedDay == null) {
      return;
    }
    final double? localDx = _localDxForDay(globalPosition, resolvedDay);
    if (localDx == null) {
      return;
    }
    final int currentSlot = _slotFromDx(localDx);
    final int anchor = _dragAnchorSlot!;
    final int start = math.min(anchor, currentSlot);
    final int end = math.max(anchor, currentSlot) + 1;
    setState(() {
      _draggingDayIndex = resolvedDay;
      _activeSelection = _ScheduleSelection(
        dayIndex: resolvedDay,
        startSlot: start,
        endSlot: math.min(_maxSelectableSlots, end),
      );
    });
  }

  bool _edgeSnap(int direction) {
    if (!_timelineScrollController.hasClients) {
      return false;
    }
    final ScrollPosition position = _timelineScrollController.position;
    final DateTime now = DateTime.now();
    if (now.difference(_lastSnap) < _snapInterval) {
      return false;
    }
    final _ScheduleSelection? selection = _activeSelection;
    if (selection != null) {
      if (direction > 0 && selection.endSlot >= _maxSelectableSlots) {
        _refreshSelectionForPointer();
        return false;
      }
      if (direction < 0 && selection.startSlot <= 0) {
        _refreshSelectionForPointer();
        return false;
      }
    }
    final double hourWidth = _scheduleHourWidth;
    if (hourWidth <= 0) {
      return false;
    }
    final double minExtent = position.minScrollExtent;
    final double maxExtent = position.maxScrollExtent;
    final double currentOffset = position.pixels;
    final int baseIndex = (currentOffset / hourWidth).round();
    final int nextIndex = direction > 0 ? baseIndex + 1 : baseIndex - 1;
    final double targetOffset =
        (nextIndex * hourWidth).clamp(minExtent, maxExtent);
    if ((targetOffset - currentOffset).abs() < 0.5) {
      return false;
    }
    _snapScrollListener ??= _refreshSelectionForPointer;
    if (!_snapListenerAttached) {
      _timelineScrollController.addListener(_snapScrollListener!);
      _snapListenerAttached = true;
    }
    _timelineScrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          _detachSnapListener();
          _refreshSelectionForPointer();
        });
    _lastSnap = now;
    return true;
  }

  void _detachSnapListener() {
    if (_snapListenerAttached &&
        _snapScrollListener != null &&
        _timelineScrollController.hasClients) {
      _timelineScrollController.removeListener(_snapScrollListener!);
      _snapListenerAttached = false;
    }
  }

  int? _resolveDayFromGlobal(Offset globalPosition) {
    for (int index = 0; index < _dayGridKeys.length; index++) {
      final RenderBox? box =
          _dayGridKeys[index].currentContext?.findRenderObject() as RenderBox?;
      if (box == null) {
        continue;
      }
      final Offset topLeft = box.localToGlobal(Offset.zero);
      final Rect bounds = topLeft & box.size;
      if (bounds.contains(globalPosition)) {
        return index;
      }
    }
    return null;
  }

  double? _localDxForDay(Offset globalPosition, int dayIndex) {
    if (dayIndex < 0 || dayIndex >= _dayGridKeys.length) {
      return null;
    }
    final RenderBox? box =
        _dayGridKeys[dayIndex].currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return null;
    }
    final Offset local = box.globalToLocal(globalPosition);
    return local.dx;
  }

  int _slotFromDx(double dx) {
    final double safeDx = dx.isNaN ? 0 : dx;
    final double maxDx = math.max(0, _totalSlots * _slotWidth - 0.01);
    final double clamped = safeDx.clamp(0, maxDx).toDouble();
    final int slot = (clamped / _slotWidth).floor();
    return _clampInt(slot, 0, _maxSelectableSlots - 1);
  }

  _ScheduleSelection _normalizeSelection(_ScheduleSelection selection) {
    final int safeDay =
        _clampInt(selection.dayIndex, 0, AppConstants.scheduleDaysEn.length - 1);
    final int maxSlot = math.max(1, _maxSelectableSlots);
    final int start =
        _clampInt(math.min(selection.startSlot, selection.endSlot), 0, maxSlot - 1);
    final int end =
        _clampInt(math.max(selection.startSlot, selection.endSlot), start + 1, maxSlot);
    return _ScheduleSelection(dayIndex: safeDay, startSlot: start, endSlot: end);
  }

  bool _selectionsOverlap(_ScheduleSelection a, _ScheduleSelection b) {
    if (a.dayIndex != b.dayIndex) {
      return false;
    }
    return a.startSlot < b.endSlot && a.endSlot > b.startSlot;
  }

  String _formatSelection(_ScheduleSelection selection) {
    final _ScheduleSelection normalized = _normalizeSelection(selection);
    final int safeDay =
        _clampInt(normalized.dayIndex, 0, AppConstants.scheduleDaysTh.length - 1);
    final String dayLabel = AppConstants.scheduleDaysTh[safeDay];
    final TimeOfDay startTime = _timeForSlot(normalized.startSlot);
    final TimeOfDay endTime = _timeForSlot(normalized.endSlot);
    return '$dayLabel ${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  String _formatHourLabel(int hour) {
    final int normalizedHour = _clampInt(hour, 0, 23);
    return '${normalizedHour.toString().padLeft(2, '0')}:00';
  }

  List<List<int>> _calculateTutorCounts() {
    final int dayCount = AppConstants.scheduleDaysEn.length;
    final int slotCount = _totalSlots;
    final int interval = AppConstants.scheduleIntervalMinutes;
    final int baseMinutes = AppConstants.scheduleStartHour * 60;
    if (slotCount <= 0 || interval <= 0) {
      return List<List<int>>.generate(dayCount, (_) => <int>[]);
    }

    final List<List<int>> counts =
        List<List<int>>.generate(dayCount, (_) => List<int>.filled(slotCount, 0));
    for (final tutor in _allTutors) {
      final dynamic scheduleRaw = tutor['schedule'];
      if (scheduleRaw is! Map) {
        continue;
      }
      final Map<String, dynamic> schedule =
          Map<String, dynamic>.from(scheduleRaw as Map);
      for (int dayIndex = 0; dayIndex < dayCount; dayIndex++) {
        final String dayKey = AppConstants.scheduleDaysEn[dayIndex];
        final dynamic blocksRaw = schedule[dayKey];
        if (blocksRaw is! List) {
          continue;
        }
        for (final blockRaw in List<dynamic>.from(blocksRaw)) {
          if (blockRaw is! Map) {
            continue;
          }
          final Map<String, dynamic> block = Map<String, dynamic>.from(blockRaw);
          final String type = (block['type'] as String? ?? '').toLowerCase().trim();
          if (type != 'teaching') {
            continue;
          }
          final String? startTime = block['startTime'] as String?;
          final String? endTime = block['endTime'] as String?;
          if (startTime == null || endTime == null) {
            continue;
          }
          final int startMinutes = _timeStringToMinutes(startTime);
          final int endMinutes = _timeStringToMinutes(endTime);
          if (endMinutes <= startMinutes) {
            continue;
          }
          int startSlot = ((startMinutes - baseMinutes) / interval).floor();
          int endSlot = ((endMinutes - baseMinutes) / interval).ceil();
          if (endSlot <= 0 || startSlot >= slotCount) {
            continue;
          }
          startSlot = math.max(0, math.min(slotCount - 1, startSlot));
          endSlot = math.max(0, math.min(slotCount, endSlot));
          if (endSlot <= startSlot) {
            continue;
          }
          for (int slot = startSlot; slot < endSlot; slot++) {
            counts[dayIndex][slot] += 1;
          }
        }
      }
    }
    return counts;
  }

  List<Widget> _buildSelectionHighlights(int dayIndex) {
    final List<Widget> highlights = [];
    for (final selection in _selectedRanges) {
      if (selection.dayIndex == dayIndex) {
        highlights.add(_buildSelectionHighlight(selection, false));
      }
    }
    final _ScheduleSelection? active = _activeSelection;
    if (active != null && active.dayIndex == dayIndex) {
      highlights.add(_buildSelectionHighlight(active, true));
    }
    return highlights;
  }

  Widget _buildSelectionHighlight(
      _ScheduleSelection selection, bool isActive) {
    final _ScheduleSelection normalized = _normalizeSelection(selection);
    final double left = normalized.startSlot * _slotWidth;
    final double desiredWidth = math.max(
      _slotWidth,
      (normalized.endSlot - normalized.startSlot) * _slotWidth,
    );
    final double maxWidth =
        math.max(0, _maxSelectableSlots * _slotWidth - left);
    final double highlightWidth = math.min(maxWidth, desiredWidth);
    final double opacity = isActive ? 0.75 : 0.6;
    return Positioned(
      left: left,
      top: 6,
      bottom: 6,
      child: Container(
        width: highlightWidth,
        decoration: BoxDecoration(
          color: AppConstants.highlightBg.withOpacity(opacity),
          border: Border.all(
            color: AppConstants.highlightBorder,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildTutorCountOverlay(List<int> slotCounts, TextStyle textStyle) {
    if (slotCounts.isEmpty) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: Stack(
        children: [
          for (int slot = 0; slot < slotCounts.length; slot++)
            if (slotCounts[slot] > 0)
              Positioned(
                left: slot * _slotWidth,
                width: _slotWidth,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    slotCounts[slot].toString(),
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  int _timeStringToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      return AppConstants.scheduleStartHour * 60;
    }
    final int hour = int.tryParse(parts[0]) ?? AppConstants.scheduleStartHour;
    final int minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  TimeOfDay _timeForSlot(int slot) {
    final int safeSlot = _clampInt(slot, 0, _maxSelectableSlots);
    final int totalMinutes =
        AppConstants.scheduleStartHour * 60 + safeSlot * AppConstants.scheduleIntervalMinutes;
    final int hour = totalMinutes ~/ 60;
    final int minute = totalMinutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int _clampInt(int value, int minValue, int maxValue) {
    if (maxValue <= minValue) {
      return minValue;
    }
    return math.min(math.max(value, minValue), maxValue);
  }

  String _statusMessage() {
    final bool hasSubjectFilter = _selectedSubjectLabels.isNotEmpty;
    final bool hasTimeFilter = _selectedRanges.isNotEmpty;
    if (!hasSubjectFilter && !hasTimeFilter) {
      return 'ยังไม่ใช้ตัวกรอง – แสดงครูทั้งหมด';
    }
    final List<String> segments = [];
    if (hasSubjectFilter) {
      final List<String> subjects = _sortedSelectedSubjects();
      final String subjectText = subjects.length <= 2
          ? 'วิชา: ${subjects.join(', ')}'
          : 'วิชา ${subjects.length} รายการ';
      segments.add(subjectText);
    }
    if (hasTimeFilter) {
      final List<String> selections =
          _selectedRanges.map(_formatSelection).toList(growable: false);
      final String timeText = selections.length <= 2
          ? 'เวลา: ${selections.join(', ')}'
          : 'เวลา ${selections.length} ช่วง';
      segments.add(timeText);
    }
    return 'ตัวกรองที่ใช้งาน: ${segments.join(' | ')}';
  }

  Widget _buildTutorSection() {
    final header = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppConstants.lightPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ครูในระบบ (${_filteredTutors.length}/${_allTutors.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _listSubTitle(),
            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
        ],
      ),
    );

    if (_filteredTutors.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.search_off, size: 64, color: Color(0xFFBDBDBD)),
                SizedBox(height: 16),
                Text(
                  'ไม่พบครูที่ตรงกับตัวกรอง',
                  style: TextStyle(color: Color(0xFF757575)),
                ),
                Text(
                  'ลองปรับตัวกรองใหม่อีกครั้ง',
                  style: TextStyle(color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 12),
        ListView.separated(
          itemCount: _filteredTutors.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final tutor = _filteredTutors[index];
            return _buildTutorCard(tutor);
          },
        ),
      ],
    );
  }

  String _listSubTitle() {
    final bool hasSubjectFilter = _selectedSubjectLabels.isNotEmpty;
    final bool hasTimeFilter = _selectedRanges.isNotEmpty;
    if (!hasSubjectFilter && !hasTimeFilter) {
      return 'กำลังแสดงครูทั้งหมด';
    }
    final List<String> segments = [];
    if (hasSubjectFilter) {
      final List<String> subjects = _sortedSelectedSubjects();
      final String subjectText = subjects.length == 1
          ? 'วิชา 1 รายการ (${subjects.first})'
          : 'วิชา ${subjects.length} รายการ';
      segments.add(subjectText);
    }
    if (hasTimeFilter) {
      final List<String> selections =
          _selectedRanges.map(_formatSelection).toList(growable: false);
      final String timeText = selections.length == 1
          ? 'เวลา 1 ช่วง (${selections.first})'
          : 'เวลา ${selections.length} ช่วง';
      segments.add(timeText);
    }
    return segments.join(' | ');
  }

  Widget _buildTutorCard(Map<String, dynamic> tutor) {
    final imageBytes = _decodeImage(tutor['profileImageBase64'] as String?);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.tutorDashboard,
              arguments: {
                'tutorId': tutor['id'],
                'readOnly': false,
                'fromAdmin': true,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppConstants.lightPink,
                  backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                  child: imageBytes == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor['nickname']?.toString() ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'แตะเพื่อดูโปรไฟล์',
                        style: TextStyle(color: Color(0xFF757575), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => _confirmDelete(tutor),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: AppConstants.deleteButtonPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'ลบ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> tutor) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('ยืนยันการลบ'),
              content: Text('ต้องการลบครู "${tutor['nickname']}" ใช่หรือไม่?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.logoutGradient1),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('ลบ'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) return;
    await _storageService.deleteTutor(tutor['id'] as String);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ลบครูสำเร็จ'),
        backgroundColor: Colors.green,
      ),
    );
    _loadTutors();
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('ยืนยันการออกจากระบบ'),
          content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: const Text('ออกจากระบบ'),
            ),
          ],
        );
      },
    );
  }

  List<String> _sortedSelectedSubjects() {
    final List<String> subjects = _selectedSubjectLabels
        .where((label) => label != 'ทั้งหมด')
        .toList();
    subjects.sort();
    return subjects;
  }

  List<String> get _subjectLabels {
    final labels = <String>['ทั้งหมด'];
    for (final entry in AppConstants.subjectLevels.entries) {
      if (entry.value.isEmpty) {
        labels.add(entry.key);
      } else {
        for (final level in entry.value) {
          labels.add('${entry.key} ($level)');
        }
      }
    }
    return labels;
  }
}
