import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/tutor/tutor_dashboard_screen.dart';
import 'screens/tutor/tutor_login_screen.dart';
import 'screens/tutor/tutor_register_screen.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;

  if (firebaseOptions != null) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tutor Scheduler',
      theme: AppTheme.lightTheme(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case AppRoutes.adminLogin:
            return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
          case AppRoutes.adminDashboard:
            return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
          case AppRoutes.tutorLogin:
            return MaterialPageRoute(builder: (_) => const TutorLoginScreen());
          case AppRoutes.tutorRegister:
            return MaterialPageRoute(builder: (_) => const TutorRegisterScreen());
          case AppRoutes.tutorDashboard:
            return MaterialPageRoute(
              builder: (_) => const TutorDashboardScreen(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('ไม่พบหน้า')), 
              ),
            );
        }
      },
    );
  }
}
