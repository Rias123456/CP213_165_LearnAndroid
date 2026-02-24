import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/tutor_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../utils/error_handler.dart';
import '../../utils/validators.dart';

class TutorRegisterScreen extends StatefulWidget {
  const TutorRegisterScreen({super.key});

  @override
  State<TutorRegisterScreen> createState() => _TutorRegisterScreenState();
}

class _TutorRegisterScreenState extends State<TutorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _lineController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tutorService = TutorService();
  final _picker = ImagePicker();

  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _lineController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
    });
  }

  Future<void> _showPickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppConstants.primaryPurple),
                  title: const Text('ถ่ายรูป'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: AppConstants.primaryPurple),
                  title: const Text('เลือกจากแกลเลอรี่'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_imageBytes == null) {
      showSnackBar(context, 'กรุณาเลือกรูปโปรไฟล์', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    try {
      final data = {
        'nickname': _nicknameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'lineId': _lineController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'currentActivity': '',
        'travelTime': '',
        'teachingCondition': '',
      };
      final id = await _tutorService.registerTutor(
        data: data,
        imageBytes: _imageBytes!,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (id == null) {
        showErrorDialog(context, 'ไม่สามารถลงทะเบียนได้');
        return;
      }
      showSuccessDialog(
        context,
        title: 'ลงทะเบียน สำเร็จ',
        message: 'บัญชีของคุณถูกสร้างเรียบร้อยแล้ว',
        buttonText: 'กลับหน้าแรก',
        onConfirmed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (Route<dynamic> route) => false,
          );
        },
        icon: Icons.check_circle,
        iconColor: Colors.green,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showErrorDialog(context, 'ไม่สามารถลงทะเบียนได้\n${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.appBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.appBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        foregroundColor: Colors.black87,
        title: const Text(
          'ลงทะเบียนติวเตอร์',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black54, width: 1.2),
                          ),
                          child: ClipOval(
                            child: _imageBytes != null
                                ? Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.person_outline,
                                    color: Colors.grey.shade600,
                                    size: 48,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showPickerSheet,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.insert_drive_file_outlined,
                            size: 16, color: Colors.black87),
                        SizedBox(width: 6),
                        Text(
                          'เลือกรูปโปรไฟล์',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nicknameController,
                          hint: 'ชื่อเล่น',
                          icon: Icons.person_outline,
                          validator: (value) => validateRequired(value, 'ชื่อเล่น'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          hint: 'เบอร์โทรศัพท์',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: validatePhoneNumber,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _lineController,
                          hint: 'ไอดีไลน์',
                          icon: Icons.chat_bubble_outline,
                          validator: validateLineId,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'อีเมล',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'รหัสผ่าน',
                          icon: Icons.lock_outline,
                          obscure: false,
                          validator: validatePassword,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.black, width: 1.4),
                              ),
                            ),
                            onPressed: _loading ? null : _submit,
                            child: const Text(
                              'ลงทะเบียน',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppConstants.primaryPurple),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF616161)),
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}
