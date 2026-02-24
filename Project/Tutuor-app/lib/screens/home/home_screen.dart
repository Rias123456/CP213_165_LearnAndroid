import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfNeeded());
  }

  Future<void> _redirectIfNeeded() async {
    final savedTutorId = await _sessionService.getSavedTutorId();
    if (!mounted) return;
    if (savedTutorId != null && savedTutorId.isNotEmpty) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.tutorDashboard,
        arguments: {'tutorId': savedTutorId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.appBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double viewHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.of(context).size.height;
          const double logoSize = 180;
          const double spacingAfterLogo = 32;
          const double spacingBetweenButtons = 16;

          return SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewHeight),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: logoSize,
                            height: logoSize,
                            child: ClipOval(
                              child: Image.asset(
                                'lib/images/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.school,
                                  size: 96,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: spacingAfterLogo),
                          _HomeButton(
                            label: 'Admin Login',
                            icon: Icons.lock_outline,
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.adminLogin,
                            ),
                          ),
                          const SizedBox(height: spacingBetweenButtons),
                          _HomeButton(
                            label: 'ลงทะเบียนติวเตอร์',
                            icon: Icons.person_add_alt_1,
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.tutorRegister,
                            ),
                          ),
                          const SizedBox(height: spacingBetweenButtons),
                          _HomeButton(
                            label: 'เข้าสู่ระบบติวเตอร์',
                            icon: Icons.login_rounded,
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.tutorLogin,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(icon, size: 22),
        onPressed: onPressed,
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
