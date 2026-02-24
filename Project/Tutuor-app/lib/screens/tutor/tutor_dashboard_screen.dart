import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/schedule_model.dart';
import '../../services/session_service.dart';
import '../../services/tutor_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../utils/error_handler.dart';
import '../../utils/validators.dart';
import '../../widgets/schedule_grid.dart';

const double kLeftGutter = 72.0;
const double kHourWidth = 112.0;
const double kRowHeight = 60.0;
const int kStartHour = 8;
const int kEndHour = 21;
const int kInteractiveEndHour = 20;

double lineX(int index) => kLeftGutter + kHourWidth * index;

class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  final _tutorService = TutorService();
  final SessionService _sessionService = SessionService();

  final _realNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _lineIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _activityController = TextEditingController();
  final _teachingConditionController = TextEditingController();
  final _travelTimeController = TextEditingController();
  final FocusNode _teachingConditionFocusNode = FocusNode();
  bool _teachingConditionHasFocus = false;

  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scheduleScrollController = ScrollController();
  final GlobalKey _scheduleViewportKey = GlobalKey();

  Map<String, dynamic>? _tutor;
  Map<String, List<ScheduleBlock>> _schedule = {
    for (final day in AppConstants.scheduleDaysEn) day: <ScheduleBlock>[],
  };
  List<Map<String, String?>> _subjects = [];
  bool _loading = true;
  bool _saving = false;
  bool _readOnly = false;
  bool _fromAdmin = false;
  Uint8List? _profileImageBytes;
  String _profileImageBase64 = '';

  @override
  void initState() {
    super.initState();
    _teachingConditionFocusNode.addListener(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _teachingConditionHasFocus = _teachingConditionFocusNode.hasFocus;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    String? tutorId = args['tutorId'] as String?;
    _readOnly = args['readOnly'] as bool? ?? false;
    _fromAdmin = args['fromAdmin'] as bool? ?? false;
    tutorId ??= await _sessionService.getSavedTutorId();
    if (tutorId == null || tutorId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final String resolvedTutorId = tutorId;
    final tutor = await _tutorService.getTutorById(resolvedTutorId);
    if (!mounted) return;
    setState(() {
      _tutor = tutor;
      _loading = false;
      _profileImageBytes = null;
      if (tutor != null) {
        _realNameController.text = (tutor['realName'] ?? '') as String;
        _nicknameController.text = (tutor['nickname'] ?? '') as String;
        _lineIdController.text = (tutor['lineId'] ?? '') as String;
        _phoneController.text = (tutor['phoneNumber'] ?? '') as String;
        _activityController.text = (tutor['currentActivity'] ?? '') as String;
        _teachingConditionController.text =
            (tutor['teachingCondition'] ?? '') as String;
        _travelTimeController.text = (tutor['travelTime'] ?? '') as String;
        final imageBase64 = tutor['profileImageBase64'] as String?;
        _profileImageBase64 = imageBase64 ?? '';
        if (_profileImageBase64.isNotEmpty) {
          try {
            _profileImageBytes = base64Decode(_profileImageBase64);
          } catch (_) {
            _profileImageBytes = null;
          }
        } else {
          _profileImageBytes = null;
        }
        _subjects = ((tutor['subjects'] as List<dynamic>? ?? [])
                .map((e) => Map<String, String?>.from(e as Map))
                .toList())
            .cast<Map<String, String?>>();
        final scheduleMap = Map<String, dynamic>.from(tutor['schedule'] as Map? ?? {});
        _schedule = {
          for (final day in AppConstants.scheduleDaysEn)
            day: (scheduleMap[day] as List<dynamic>? ?? [])
                .map((e) => ScheduleBlock.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList(),
        };
      } else {
        _teachingConditionController.clear();
      }
    });
  }

  @override
  void dispose() {
    _realNameController.dispose();
    _nicknameController.dispose();
    _lineIdController.dispose();
    _phoneController.dispose();
    _activityController.dispose();
    _teachingConditionController.dispose();
    _travelTimeController.dispose();
    _teachingConditionFocusNode.dispose();
    _scheduleScrollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_tutor == null) return;
    setState(() => _saving = true);
    final tutorId = _tutor!['id'] as String;
    final payload = {
      'realName': _realNameController.text.trim(),
      'nickname': _nicknameController.text.trim(),
      'lineId': _lineIdController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'currentActivity': _activityController.text.trim(),
      'travelTime': _travelTimeController.text.trim(),
      'teachingCondition': _teachingConditionController.text.trim(),
      'subjects': _subjects,
      'schedule': {
        for (final day in AppConstants.scheduleDaysEn)
          day: _schedule[day]?.map((e) => e.toJson()).toList() ?? [],
      },
      'profileImageBase64': _profileImageBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final success = await _tutorService.updateTutor(tutorId, payload);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      final updatedData = Map<String, dynamic>.from(payload);
      updatedData.remove('updatedAt');
      setState(() {
        _tutor = {
          ...?_tutor,
          ...updatedData,
          'id': tutorId,
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('บันทึกข้อมูลสำเร็จ'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      showErrorDialog(context, 'ไม่สามารถบันทึกข้อมูลได้');
    }
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    if (_readOnly) return;
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _profileImageBytes = bytes;
        _profileImageBase64 = base64Encode(bytes);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเลือกรูปได้: $error')),
      );
    }
  }

  void _removeProfileImage() {
    if (_readOnly) return;
    setState(() {
      _profileImageBytes = null;
      _profileImageBase64 = '';
    });
  }

  Future<void> _showImageOptions() async {
    if (_readOnly) return;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppConstants.primaryPurple),
                title: const Text('เลือกรูปจากแกลเลอรี'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
              if (_profileImageBase64.isNotEmpty)
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('ลบรูปโปรไฟล์'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage();
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createBlock(TimeSlot slot, String type) async {
    if (_readOnly) return;
    final blocks = _schedule[slot.day] ?? [];
    if (type == 'busy') {
      final block = ScheduleBlock(
        blockId: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: slot.startTime,
        endTime: slot.endTime,
        type: 'busy',
        note: null,
      );
      setState(() {
        blocks.add(block);
        _schedule[slot.day] = blocks;
      });
      return;
    }

    final note = await _promptTeachingNote(
      title: '${_dayName(slot.day)} ${slot.startTime} - ${slot.endTime}',
    );
    if (note == null) {
      return;
    }
    final block = ScheduleBlock(
      blockId: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: slot.startTime,
      endTime: slot.endTime,
      type: 'teaching',
      note: note.isEmpty ? null : note,
    );
    setState(() {
      blocks.add(block);
      _schedule[slot.day] = blocks;
    });
  }

  Future<String?> _promptTeachingNote({required String title, String? initialNote}) async {
    final controller = TextEditingController(text: initialNote ?? '');
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'รายละเอียด',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'เช่น น้องกัส คณิต ม.2',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.4),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('ยกเลิก'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                      child: const Text('ยืนยัน'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    return result;
  }

  void _onEditBlock(String day, ScheduleBlock block) {
    if (_readOnly) return;
    if (block.type == 'busy') {
      _showBusyBlockDialog(day, block);
    } else {
      _showTeachingBlockDialog(day, block);
    }
  }

  Future<void> _showBusyBlockDialog(String day, ScheduleBlock block) async {
    final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'ไม่ว่าง',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ต้องการลบบล็อกเวลานี้หรือไม่?',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('ยกเลิก'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('ลบบล็อก'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
    if (!mounted || !confirmed) return;
    setState(() {
      final blocks = _schedule[day] ?? [];
      blocks.removeWhere((b) => b.blockId == block.blockId);
      _schedule[day] = blocks;
    });
  }

  Future<void> _showTeachingBlockDialog(String day, ScheduleBlock block) async {
    final controller = TextEditingController(text: block.note ?? '');
    final result = await showDialog<_TeachingDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_dayName(day)} ${block.startTime} - ${block.endTime}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'รายละเอียด',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'เช่น ชื่อนักเรียนหรือหมายเหตุ',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.4),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pop(const _TeachingDialogResult(delete: true)),
                      child: const Text(
                        'ลบ',
                        style: TextStyle(color: Color(0xFFFF6B6B)),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('ยกเลิก'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(
                        _TeachingDialogResult(note: controller.text.trim()),
                      ),
                      child: const Text('ยืนยัน'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    if (!mounted || result == null) return;
    if (result.delete) {
      setState(() {
        final blocks = _schedule[day] ?? [];
        blocks.removeWhere((b) => b.blockId == block.blockId);
        _schedule[day] = blocks;
      });
      return;
    }
    setState(() {
      final blocks = _schedule[day] ?? [];
      final index = blocks.indexWhere((b) => b.blockId == block.blockId);
      if (index != -1) {
        blocks[index] = block.copyWith(
          note: result.note?.isEmpty == true ? null : result.note,
        );
        _schedule[day] = blocks;
      }
    });
  }

  void _handleBackNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    }
  }

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('ยืนยันการออกจากระบบ'),
          content: Text(_readOnly
              ? 'คุณต้องการกลับไปหน้าก่อนหน้าหรือไม่?'
              : 'คุณต้องการออกจากระบบใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(context).pop();
                if (_readOnly || _fromAdmin) {
                  _handleBackNavigation();
                  return;
                }
                await _sessionService.clearTutorSession();
                if (!mounted) {
                  return;
                }
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: Text(_readOnly || _fromAdmin ? 'กลับ' : 'ออกจากระบบ'),
            ),
          ],
        );
      },
    );
  }

  String _dayName(String english) {
    final index = AppConstants.scheduleDaysEn.indexOf(english);
    if (index == -1) return english;
    return AppConstants.scheduleDaysTh[index];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppConstants.appBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppConstants.primaryPurple),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppConstants.appBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 20),
                      _buildSubjects(),
                      const SizedBox(height: 16),
                      _buildTeachingConditionField(),
                      const SizedBox(height: 20),
                      _buildSchedule(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
            if (_saving)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: AppConstants.primaryPurple),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _buildProfileHeader()),
          const SizedBox(height: 24),
          _buildInput('ชื่อจริง นามสกุล', Icons.badge_outlined, _realNameController,
              enabled: !_readOnly),
          const SizedBox(height: 16),
          _buildInput('ชื่อเล่น', Icons.person_outline, _nicknameController,
              enabled: !_readOnly),
          const SizedBox(height: 16),
          _buildInput('ID LINE', Icons.chat_bubble_outline, _lineIdController,
              enabled: !_readOnly),
          const SizedBox(height: 16),
          _buildInput('เบอร์โทรศัพท์', Icons.phone_outlined, _phoneController,
              keyboardType: TextInputType.phone,
              validator: validatePhoneNumber,
              enabled: !_readOnly),
          const SizedBox(height: 16),
          _buildInput('วุฒิการศึกษา', Icons.school_outlined, _activityController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 1,
              hintText: 'เช่น แพทย์ มหิดล',
              hintMaxLines: 2,
              labelMaxLines: 1,
              enabled: !_readOnly),
          const SizedBox(height: 16),
          _buildInput('ระยะเวลาเดินทาง', Icons.access_time, _travelTimeController,
              enabled: !_readOnly),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final ButtonStyle baseStyle = TextButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      side: const BorderSide(color: Colors.black, width: 1.4),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_readOnly)
          SizedBox(
            height: 56,
            child: TextButton(
              style: baseStyle,
              onPressed: _saving ? null : _save,
              child: const Text('บันทึก'),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'โหมดดูอย่างเดียว',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        if (!_readOnly) const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: TextButton(
            style: baseStyle,
            onPressed: _fromAdmin ? _handleBackNavigation : _logout,
            child: Text(_fromAdmin
                ? 'กลับหน้าหลัก'
                : (_readOnly ? 'กลับ' : 'ออกจากระบบ')),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nicknameController,
      builder: (context, value, _) {
        final fallbackNickname = (_tutor?['nickname'] as String? ?? '').trim();
        final nickname = value.text.trim().isNotEmpty
            ? value.text.trim()
            : fallbackNickname;
        final title = nickname.isNotEmpty ? 'ครู$nickname' : 'ครู';
        final avatar = CircleAvatar(
          radius: 82,
          backgroundColor: Colors.white,
          backgroundImage:
              _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
          child: _profileImageBytes == null
              ? const Icon(Icons.person, size: 48, color: Color(0xFFBDBDBD))
              : null,
        );
        return Column(
          children: [
            GestureDetector(
              onTap: _readOnly ? null : _showImageOptions,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  avatar,
                  if (!_readOnly)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInput(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines = 1,
    int? minLines,
    bool enabled = true,
    String? hintText,
    int? hintMaxLines,
    int? labelMaxLines,
    FocusNode? focusNode,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool? alignLabelWithHint,
    FloatingLabelBehavior? floatingLabelBehavior,
    TextStyle? hintStyle,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Colors.black,
        width: 1.4,
      ),
    );
    final effectiveMinLines =
        minLines ?? (maxLines == null ? 1 : null);
    final bool? effectiveAlignLabelWithHint = alignLabelWithHint ??
        ((maxLines != null && maxLines > 1) ||
            (effectiveMinLines != null && effectiveMinLines > 1) ||
            (labelMaxLines != null && labelMaxLines > 1));
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: effectiveMinLines,
      validator: validator,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      decoration: InputDecoration(
        label: Text(
          label,
          maxLines: labelMaxLines ?? 1,
          softWrap: true,
          style: const TextStyle(color: Colors.black87),
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.black87),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.black, width: 1.6),
        ),
        disabledBorder: border,
        hintText: hintText,
        hintStyle: hintStyle ?? const TextStyle(color: Colors.black54),
        hintMaxLines: hintMaxLines,
        alignLabelWithHint: effectiveAlignLabelWithHint,
        floatingLabelBehavior: floatingLabelBehavior,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    );
  }

  Widget _buildTeachingConditionField() {
    const String exampleText =
        'เช่น เลขประถมสอนได้เฉพาะ ประถมต้น, อย่างน้อย 2 ชม. ฯลฯ';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: _buildInput(
        'เงื่อนไขการสอน',
        Icons.fact_check_outlined,
        _teachingConditionController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        minLines: 3,
        hintText: exampleText,
        hintStyle: const TextStyle(color: Colors.grey),
        hintMaxLines: 4,
        labelMaxLines: 1,
        enabled: !_readOnly,
        alignLabelWithHint: true,
        textAlignVertical: TextAlignVertical.top,
        focusNode: _teachingConditionFocusNode,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Widget _buildSubjects() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('วิชาที่สอน',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (!_readOnly)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.black87, size: 28),
                  onPressed: _addSubject,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_subjects.isEmpty)
            const Center(
              child: Text('ยังไม่ได้เลือกวิชา',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subjects.map((subject) {
                final label = subject['level'] == null
                    ? subject['subject']
                    : '${subject['subject']} (${subject['level']})';
                return Chip(
                  label: Text(label ?? ''),
                  backgroundColor: AppConstants.lightPink,
                  labelStyle: const TextStyle(color: Colors.black87, fontSize: 13),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Colors.black
                          .withAlpha((0.5 * 255).round()),
                      width: 1,
                    ),
                  ),
                  deleteIcon: _readOnly
                      ? null
                      : const Icon(Icons.close, size: 18, color: Colors.black87),
                  onDeleted: _readOnly
                      ? null
                      : () {
                          setState(() => _subjects.remove(subject));
                        },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _addSubject() async {
    if (_readOnly) return;
    final options = <Map<String, String?>>[];
    for (final entry in AppConstants.subjectLevels.entries) {
      if (entry.value.isEmpty) {
        options.add({'subject': entry.key, 'level': null});
      } else {
        for (final level in entry.value) {
          options.add({'subject': entry.key, 'level': level});
        }
      }
    }

    final existingKeys = _subjects
        .map((e) => '${e['subject']}|${e['level'] ?? ''}')
        .toSet();
    final selectedKeys = Set<String>.from(existingKeys);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('เลือกวิชาที่สอน'),
              content: SizedBox(
                width: 320,
                height: 360,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final key = '${option['subject']}|${option['level'] ?? ''}';
                    final display = option['level'] == null
                        ? option['subject']!
                        : '${option['subject']} (${option['level']})';
                    return CheckboxListTile(
                      activeColor: AppConstants.primaryPurple,
                      value: selectedKeys.contains(key),
                      title: Text(display),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value ?? false) {
                            selectedKeys.add(key);
                          } else {
                            selectedKeys.remove(key);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final ordered = <Map<String, String?>>[];
                    for (final option in options) {
                      final key = '${option['subject']}|${option['level'] ?? ''}';
                      if (selectedKeys.contains(key)) {
                        ordered.add({
                          'subject': option['subject']!,
                          'level': option['level'],
                        });
                      }
                    }
                    setState(() {
                      _subjects
                        ..clear()
                        ..addAll(ordered);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('ยืนยัน'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSchedule() {
    final totalHours = kInteractiveEndHour - kStartHour;
    final double gridContentWidth = kHourWidth * totalHours;
    final double gridWidth = kLeftGutter + gridContentWidth;
    final double gridHeight = kRowHeight * AppConstants.scheduleDaysEn.length;
    final labels = <String>[
      for (int hour = kStartHour; hour < kEndHour; hour++)
        '${hour.toString().padLeft(2, '0')}:00',
    ];

    const headerTextStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      letterSpacing: 0.2,
      fontFeatures: [FontFeature.tabularFigures()],
      color: Color(0xFF222222),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ตารางสอน',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              key: _scheduleViewportKey,
              controller: _scheduleScrollController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: gridWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: CustomPaint(
                        size: Size(gridWidth, 44),
                        painter: _TutorTimeHeaderPainter(
                          labels: labels,
                          textStyle: headerTextStyle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: gridHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _TutorGridPainter(
                                rowCount: AppConstants.scheduleDaysEn.length,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDayColumn(gridHeight),
                              SizedBox(
                                width: gridContentWidth,
                                height: gridHeight,
                                child: ScheduleGrid(
                                  mode: ScheduleGridMode.edit,
                                  schedule: _schedule,
                                  readOnly: _readOnly,
                                  hourWidth: kHourWidth,
                                  rowHeight: kRowHeight,
                                  backgroundColor: Colors.transparent,
                                  majorLineColor: Colors.transparent,
                                  minorLineColor: Colors.transparent,
                                  scrollController: _scheduleScrollController,
                                  viewportKey: _scheduleViewportKey,
                                  startHour: kStartHour,
                                  endHour: kInteractiveEndHour,   // ✅ end hour ต้องเท่ากับ interactiveEndHour
                                  interactiveEndHour: kInteractiveEndHour,
                                  enableTouchPanSelection: false,
                                  onBlockCreated: _createBlock,
                                  onBlockUpdated: _onEditBlock,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayColumn(double gridHeight) {
    return SizedBox(
      width: kLeftGutter,
      height: gridHeight,
      child: Column(
        children: [
          for (var i = 0; i < AppConstants.scheduleDaysTh.length; i++)
            Container(
              height: kRowHeight,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                AppConstants.scheduleDaysTh[i],
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _TeachingDialogResult {
  const _TeachingDialogResult({this.note, this.delete = false});

  final String? note;
  final bool delete;
}

class _TutorTimeHeaderPainter extends CustomPainter {
  const _TutorTimeHeaderPainter({
    required this.labels,
    required this.textStyle,
        this.bottomPadding = 4,
  });

  final List<String> labels;
  final TextStyle textStyle;
  final double bottomPadding;

  @override
  void paint(Canvas canvas, Size size) {
    const textDirection = TextDirection.ltr;
    for (var index = 0; index < labels.length; index++) {
      final label = labels[index];
      final colonIndex = label.indexOf(':');
      if (colonIndex == -1) {
        continue;
      }

      final TextPainter labelPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: textDirection,
      )..layout();

      double prefixWidth = 0;
      if (colonIndex > 0) {
        final TextPainter prefixPainter = TextPainter(
          text: TextSpan(text: label.substring(0, colonIndex), style: textStyle),
          textDirection: textDirection,
        )..layout();
        prefixWidth = prefixPainter.width;
      }

      final double colonX = lineX(index);
      final double labelX = (colonX - prefixWidth)
          .clamp(0.0, size.width - labelPainter.width);
      final double baseline = size.height - bottomPadding;
      final double proposedTop = baseline - labelPainter.height;
      final double labelY = proposedTop.clamp(0.0, size.height - labelPainter.height);

      labelPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _TutorTimeHeaderPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.bottomPadding != bottomPadding;
  }
}

class _TutorGridPainter extends CustomPainter {
  const _TutorGridPainter({required this.rowCount});

  final int rowCount;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final Paint gutterPaint = Paint()
      ..color = AppConstants.scheduleGridLabelBackground;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, kLeftGutter, size.height),
      gutterPaint,
    );

    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.2;

    // Horizontal lines including top and bottom borders.
    for (int row = 0; row <= rowCount; row++) {
      final double y = kRowHeight * row;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), borderPaint);
    }

    // Vertical outline for left and right edges.
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), borderPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), borderPaint);

    // Vertical hour separators.
    final int totalHours = kEndHour - kStartHour;
    for (int column = 0; column < totalHours; column++) {
      final double x = lineX(column);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), borderPaint);
    }

    // Minor 30-minute guides.
    final Paint minorPaint = Paint()
      ..color = AppConstants.gridLineSub
      ..strokeWidth = 0.8;
    for (int column = 0; column < totalHours; column++) {
      final double x = lineX(column) + kHourWidth / 2;
      if (x >= size.width) {
        continue;
      }
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TutorGridPainter oldDelegate) {
    return oldDelegate.rowCount != rowCount;
  }
}
