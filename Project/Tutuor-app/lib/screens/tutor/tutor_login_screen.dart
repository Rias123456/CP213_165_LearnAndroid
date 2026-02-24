import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../services/tutor_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../utils/validators.dart';

class TutorLoginScreen extends StatefulWidget {
  const TutorLoginScreen({super.key});

  @override
  State<TutorLoginScreen> createState() => _TutorLoginScreenState();
}

class _TutorLoginScreenState extends State<TutorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tutorService = TutorService();
  final SessionService _sessionService = SessionService();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    try {
      final tutor = await _tutorService.loginTutor(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (tutor == null) {
        _showFailureDialog('เข้าสู่ระบบไม่สำเร็จ', 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
        return;
      }
      final String? tutorId = tutor['id'] as String?;
      if (tutorId != null && tutorId.isNotEmpty) {
        await _sessionService.saveTutorSession(tutorId);
      }
      final Map<String, dynamic>? navArgs =
          tutorId != null && tutorId.isNotEmpty ? {'tutorId': tutorId} : null;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.tutorDashboard,
        arguments: navArgs,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      debugPrint('Tutor login failed: $e');
      _showFailureDialog('เกิดข้อผิดพลาด', 'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่อีกครั้ง');
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
          'ล็อกอินติวเตอร์',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipOval(
                          child: Image.asset(
                            'lib/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person_outline,
                              size: 64,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildField(
                              controller: _emailController,
                              hint: 'อีเมล',
                              keyboardType: TextInputType.emailAddress,
                              validator: validateEmail,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _passwordController,
                              hint: 'รหัสผ่าน',
                              validator: (value) => validateRequired(value, 'รหัสผ่าน'),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!_loading) {
                                  _login();
                                }
                              },
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.lightPurple,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(color: Colors.black, width: 1.4),
                                  ),
                                ),
                                onPressed: _loading ? null : _login,
                                child: const Text(
                                  'เข้าสู่ระบบ',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
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

  void _showFailureDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ตกลง', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
